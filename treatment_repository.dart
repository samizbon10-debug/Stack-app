import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/treatment_model.dart';
import '../../../../services/firebase_service.dart';

/// Treatment Repository for CRUD operations
class TreatmentRepository {
  final FirebaseFirestore _firestore;
  final Box _cacheBox;
  final Uuid _uuid = const Uuid();

  TreatmentRepository({
    required FirebaseFirestore firestore,
    required Box cacheBox,
  })  : _firestore = firestore,
        _cacheBox = cacheBox;

  CollectionReference<Map<String, dynamic>> get _treatmentsCollection =>
      _firestore.collection('treatments');

  /// Create a new treatment
  Future<TreatmentModel> createTreatment({
    required String patientId,
    required String userId,
    required String category,
    required DateTime date,
    String? toothNumber,
    List<String>? toothNumbers,
    String diagnosis = '',
    String treatmentNotes = '',
    List<String> materials = const [],
    String progressNotes = '',
    String status = 'planned',
    double? cost,
    List<TreatmentImage> images = const [],
  }) async {
    final treatmentId = _uuid.v4();
    final now = DateTime.now();

    final treatment = TreatmentModel(
      treatmentId: treatmentId,
      patientId: patientId,
      userId: userId,
      category: category,
      toothNumber: toothNumber,
      toothNumbers: toothNumbers,
      date: date,
      diagnosis: diagnosis,
      treatmentNotes: treatmentNotes,
      materials: materials,
      progressNotes: progressNotes,
      status: status,
      cost: cost,
      images: images,
      createdAt: now,
      updatedAt: now,
    );

    // Save to Firestore
    await _treatmentsCollection.doc(treatmentId).set(treatment.toFirestore());

    // Save to local cache
    await _cacheBox.put(treatmentId, treatment.toJson());

    return treatment;
  }

  /// Get a treatment by ID
  Future<TreatmentModel?> getTreatment(String treatmentId) async {
    // Try cache first
    final cachedData = _cacheBox.get(treatmentId);
    if (cachedData != null) {
      return TreatmentModel.fromJson(Map<String, dynamic>.from(cachedData));
    }

    // Fetch from Firestore
    final doc = await _treatmentsCollection.doc(treatmentId).get();
    if (doc.exists) {
      final treatment = TreatmentModel.fromFirestore(doc);
      // Update cache
      await _cacheBox.put(treatmentId, treatment.toJson());
      return treatment;
    }
    return null;
  }

  /// Get all treatments for a patient
  Future<List<TreatmentModel>> getPatientTreatments(String patientId) async {
    final snapshot = await _treatmentsCollection
        .where('patientId', isEqualTo: patientId)
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final treatment = TreatmentModel.fromFirestore(doc);
      _cacheBox.put(treatment.treatmentId, treatment.toJson());
      return treatment;
    }).toList();
  }

  /// Get all treatments for a user
  Future<List<TreatmentModel>> getUserTreatments(String userId) async {
    final snapshot = await _treatmentsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final treatment = TreatmentModel.fromFirestore(doc);
      _cacheBox.put(treatment.treatmentId, treatment.toJson());
      return treatment;
    }).toList();
  }

  /// Get treatments by category
  Future<List<TreatmentModel>> getTreatmentsByCategory(
    String userId,
    String category,
  ) async {
    final snapshot = await _treatmentsCollection
        .where('userId', isEqualTo: userId)
        .where('category', isEqualTo: category)
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map((doc) => TreatmentModel.fromFirestore(doc)).toList();
  }

  /// Stream treatments for a patient
  Stream<List<TreatmentModel>> streamPatientTreatments(String patientId) {
    return _treatmentsCollection
        .where('patientId', isEqualTo: patientId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final treatment = TreatmentModel.fromFirestore(doc);
        _cacheBox.put(treatment.treatmentId, treatment.toJson());
        return treatment;
      }).toList();
    });
  }

  /// Stream all treatments for a user
  Stream<List<TreatmentModel>> streamUserTreatments(String userId) {
    return _treatmentsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => TreatmentModel.fromFirestore(doc)).toList();
    });
  }

  /// Update a treatment
  Future<void> updateTreatment(TreatmentModel treatment) async {
    final updatedTreatment = treatment.copyWith(updatedAt: DateTime.now());

    // Update in Firestore
    await _treatmentsCollection
        .doc(treatment.treatmentId)
        .update(updatedTreatment.toFirestore());

    // Update cache
    await _cacheBox.put(treatment.treatmentId, updatedTreatment.toJson());
  }

  /// Add image to treatment
  Future<void> addImageToTreatment(
    String treatmentId,
    TreatmentImage image,
  ) async {
    final treatment = await getTreatment(treatmentId);
    if (treatment == null) return;

    final updatedImages = [...treatment.images, image];
    await updateTreatment(treatment.copyWith(images: updatedImages));
  }

  /// Remove image from treatment
  Future<void> removeImageFromTreatment(
    String treatmentId,
    String imageId,
  ) async {
    final treatment = await getTreatment(treatmentId);
    if (treatment == null) return;

    final updatedImages =
        treatment.images.where((img) => img.imageId != imageId).toList();
    await updateTreatment(treatment.copyWith(images: updatedImages));
  }

  /// Delete a treatment
  Future<void> deleteTreatment(String treatmentId) async {
    // Delete from Firestore
    await _treatmentsCollection.doc(treatmentId).delete();

    // Delete from cache
    await _cacheBox.delete(treatmentId);
  }

  /// Get treatment count by category
  Future<int> getTreatmentCountByCategory(
    String userId,
    String category,
  ) async {
    final snapshot = await _treatmentsCollection
        .where('userId', isEqualTo: userId)
        .where('category', isEqualTo: category)
        .count()
        .get();

    return snapshot.count ?? 0;
  }

  /// Get treatments with before/after images for gallery
  Future<List<TreatmentModel>> getGalleryTreatments(String userId) async {
    final snapshot = await _treatmentsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => TreatmentModel.fromFirestore(doc))
        .where((treatment) =>
            treatment.images.any((img) => img.label == 'before') &&
            treatment.images.any((img) => img.label == 'after'))
        .toList();
  }

  /// Get cached treatments (for offline use)
  List<TreatmentModel> getCachedTreatments() {
    return _cacheBox.values
        .map((data) => TreatmentModel.fromJson(Map<String, dynamic>.from(data)))
        .toList();
  }
}

// Provider
final treatmentRepositoryProvider = Provider<TreatmentRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final cacheBox = Hive.box('treatments_cache');
  return TreatmentRepository(firestore: firestore, cacheBox: cacheBox);
});

// Patient treatments provider
final patientTreatmentsProvider =
    StreamProvider.family<List<TreatmentModel>, String>((ref, patientId) {
  final repository = ref.watch(treatmentRepositoryProvider);
  return repository.streamPatientTreatments(patientId);
});

// User treatments provider
final userTreatmentsProvider =
    StreamProvider.family<List<TreatmentModel>, String>((ref, userId) {
  final repository = ref.watch(treatmentRepositoryProvider);
  return repository.streamUserTreatments(userId);
});

// Treatments by category provider
final treatmentsByCategoryProvider =
    FutureProvider.family<List<TreatmentModel>, ({String userId, String category})>(
        (ref, params) {
  final repository = ref.watch(treatmentRepositoryProvider);
  return repository.getTreatmentsByCategory(params.userId, params.category);
});
