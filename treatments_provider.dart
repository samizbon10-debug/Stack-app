import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/treatment_model.dart';

// Treatments State
class TreatmentsState {
  final List<TreatmentModel> treatments;
  final bool isLoading;
  final String? error;

  TreatmentsState({
    this.treatments = const [],
    this.isLoading = false,
    this.error,
  });

  TreatmentsState copyWith({
    List<TreatmentModel>? treatments,
    bool? isLoading,
    String? error,
  }) {
    return TreatmentsState(
      treatments: treatments ?? this.treatments,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  List<TreatmentModel> get orthodonticsTreatments {
    return treatments
        .where((t) => t.category == TreatmentCategory.orthodontics)
        .toList();
  }

  List<TreatmentModel> get fillingsTreatments {
    return treatments
        .where((t) => t.category == TreatmentCategory.fillings)
        .toList();
  }

  List<TreatmentModel> get scalingPolishingTreatments {
    return treatments
        .where((t) => t.category == TreatmentCategory.scalingPolishing)
        .toList();
  }

  List<TreatmentModel> get inProgressTreatments {
    return treatments
        .where((t) => t.status == TreatmentStatus.inProgress)
        .toList();
  }

  List<TreatmentModel> get completedTreatments {
    return treatments
        .where((t) => t.status == TreatmentStatus.completed)
        .toList();
  }
}

// Treatments Notifier
class TreatmentsNotifier extends StateNotifier<TreatmentsState> {
  final FirebaseFirestore _firestore;
  final String userId;

  TreatmentsNotifier({
    required FirebaseFirestore firestore,
    required this.userId,
  })  : _firestore = firestore,
        super(TreatmentsState()) {
    fetchTreatments();
  }

  void fetchTreatments() {
    state = state.copyWith(isLoading: true);
    
    _firestore
        .collection('treatments')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        final treatments = snapshot.docs
            .map((doc) => TreatmentModel.fromFirestore(doc))
            .toList();
        state = state.copyWith(
          treatments: treatments,
          isLoading: false,
        );
      },
      onError: (error) {
        state = state.copyWith(
          isLoading: false,
          error: error.toString(),
        );
      },
    );
  }

  Future<TreatmentModel?> createTreatment(TreatmentModel treatment) async {
    try {
      state = state.copyWith(isLoading: true);
      
      final docRef = await _firestore.collection('treatments').add(treatment.toMap());
      
      final newTreatment = treatment.copyWith(
        treatmentId: docRef.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      state = state.copyWith(isLoading: false);
      return newTreatment;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create treatment: $e',
      );
      return null;
    }
  }

  Future<bool> updateTreatment(TreatmentModel treatment) async {
    try {
      await _firestore
          .collection('treatments')
          .doc(treatment.treatmentId)
          .update({
            ...treatment.toMap(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to update treatment: $e');
      return false;
    }
  }

  Future<bool> deleteTreatment(String treatmentId) async {
    try {
      await _firestore.collection('treatments').doc(treatmentId).delete();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete treatment: $e');
      return false;
    }
  }

  Future<bool> addProgressNote(String treatmentId, ProgressNote note) async {
    try {
      final doc = await _firestore
          .collection('treatments')
          .doc(treatmentId)
          .get();
      
      if (doc.exists) {
        final treatment = TreatmentModel.fromFirestore(doc);
        final updatedProgressNotes = [...treatment.progressNotes, note];
        
        await doc.reference.update({
          'progressNotes': updatedProgressNotes.map((e) => e.toMap()).toList(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to add progress note: $e');
      return false;
    }
  }

  Future<bool> updateTreatmentStatus(
    String treatmentId,
    TreatmentStatus status,
  ) async {
    try {
      await _firestore
          .collection('treatments')
          .doc(treatmentId)
          .update({
            'status': _statusToString(status),
            'updatedAt': FieldValue.serverTimestamp(),
          });
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to update status: $e');
      return false;
    }
  }

  String _statusToString(TreatmentStatus status) {
    switch (status) {
      case TreatmentStatus.planned:
        return 'planned';
      case TreatmentStatus.inProgress:
        return 'in_progress';
      case TreatmentStatus.completed:
        return 'completed';
      case TreatmentStatus.cancelled:
        return 'cancelled';
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider
final treatmentsProvider =
    StateNotifierProvider.family<TreatmentsNotifier, TreatmentsState, String>(
  (ref, userId) {
    return TreatmentsNotifier(
      firestore: FirebaseFirestore.instance,
      userId: userId,
    );
  },
);

// Patient Treatments Provider
final patientTreatmentsProvider =
    FutureProvider.family<List<TreatmentModel>, String>((ref, patientId) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('treatments')
      .where('patientId', isEqualTo: patientId)
      .orderBy('date', descending: true)
      .get();

  return snapshot.docs
      .map((doc) => TreatmentModel.fromFirestore(doc))
      .toList();
});

// Single Treatment Provider
final treatmentProvider = FutureProvider.family<TreatmentModel?, String>((ref, treatmentId) async {
  final doc = await FirebaseFirestore.instance
      .collection('treatments')
      .doc(treatmentId)
      .get();

  if (doc.exists) {
    return TreatmentModel.fromFirestore(doc);
  }
  return null;
});

// Treatments by Category Provider
final treatmentsByCategoryProvider = Provider.family<List<TreatmentModel>, (String, TreatmentCategory)>((ref, params) {
  final userId = params.$1;
  final category = params.$2;
  final treatmentsState = ref.watch(treatmentsProvider(userId));
  
  return treatmentsState.treatments
      .where((t) => t.category == category)
      .toList();
});
