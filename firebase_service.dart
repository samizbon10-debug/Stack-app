import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';

// Firebase Providers
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

// Auth State Provider
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

// Current User Provider
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).when(
        data: (user) => user,
        loading: () => null,
        error: (_, __) => null,
      );
});

class FirebaseService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  FirebaseService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // Collections
  CollectionReference<Map<String, dynamic>> get usersCollection =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get patientsCollection =>
      _firestore.collection('patients');

  CollectionReference<Map<String, dynamic>> get treatmentsCollection =>
      _firestore.collection('treatments');

  CollectionReference<Map<String, dynamic>> get appointmentsCollection =>
      _firestore.collection('appointments');

  CollectionReference<Map<String, dynamic>> get galleryCollection =>
      _firestore.collection('gallery');

  CollectionReference<Map<String, dynamic>> get backupLogsCollection =>
      _firestore.collection('backup_logs');

  // ==================== USER METHODS ====================

  Future<void> createUserDocument({
    required String userId,
    required String email,
    required String displayName,
    String? photoUrl,
  }) async {
    await usersCollection.doc(userId).set({
      'userId': userId,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'googleDriveConnected': false,
      'driveFolderId': null,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
      'settings': {
        'biometricEnabled': false,
        'autoBackup': true,
        'notificationsEnabled': true,
        'theme': 'light',
      },
    });
  }

  Future<Map<String, dynamic>?> getUserDocument(String userId) async {
    final doc = await usersCollection.doc(userId).get();
    return doc.data();
  }

  Future<void> updateUserDocument(
      String userId, Map<String, dynamic> data) async {
    await usersCollection.doc(userId).update(data);
  }

  // ==================== PATIENT METHODS ====================

  Stream<List<PatientModel>> getPatients() {
    if (currentUserId == null) return Stream.value([]);
    return patientsCollection
        .where('userId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => PatientModel.fromFirestore(doc)).toList());
  }

  Future<List<PatientModel>> getPatientsOnce() async {
    if (currentUserId == null) return [];
    final snapshot = await patientsCollection
        .where('userId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => PatientModel.fromFirestore(doc)).toList();
  }

  Future<PatientModel?> getPatient(String patientId) async {
    final doc = await patientsCollection.doc(patientId).get();
    if (doc.exists) {
      return PatientModel.fromFirestore(doc);
    }
    return null;
  }

  Future<String> createPatient(PatientModel patient) async {
    final docRef = await patientsCollection.add({
      ...patient.toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Future<void> updatePatient(PatientModel patient) async {
    await patientsCollection.doc(patient.id).update({
      ...patient.toFirestore(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deletePatient(String patientId) async {
    // Delete all treatments for this patient
    final treatments = await treatmentsCollection
        .where('patientId', isEqualTo: patientId)
        .get();
    
    final batch = _firestore.batch();
    for (final doc in treatments.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(patientsCollection.doc(patientId));
    await batch.commit();
  }

  Future<List<PatientModel>> searchPatients(String query) async {
    if (currentUserId == null || query.isEmpty) return [];
    
    // Search by name (case-insensitive)
    final nameSnapshot = await patientsCollection
        .where('userId', isEqualTo: currentUserId)
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .get();
    
    // Search by phone
    final phoneSnapshot = await patientsCollection
        .where('userId', isEqualTo: currentUserId)
        .where('phone', isGreaterThanOrEqualTo: query)
        .where('phone', isLessThanOrEqualTo: '$query\uf8ff')
        .get();
    
    final patients = <String, PatientModel>{};
    for (final doc in nameSnapshot.docs) {
      patients[doc.id] = PatientModel.fromFirestore(doc);
    }
    for (final doc in phoneSnapshot.docs) {
      patients[doc.id] = PatientModel.fromFirestore(doc);
    }
    
    return patients.values.toList();
  }

  // ==================== TREATMENT METHODS ====================

  Stream<List<TreatmentModel>> getTreatments(String patientId) {
    return treatmentsCollection
        .where('patientId', isEqualTo: patientId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TreatmentModel.fromFirestore(doc)).toList());
  }

  Future<List<TreatmentModel>> getTreatmentsOnce(String patientId) async {
    final snapshot = await treatmentsCollection
        .where('patientId', isEqualTo: patientId)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs.map((doc) => TreatmentModel.fromFirestore(doc)).toList();
  }

  Stream<List<TreatmentModel>> getTreatmentsByCategory(TreatmentCategory category) {
    if (currentUserId == null) return Stream.value([]);
    return treatmentsCollection
        .where('userId', isEqualTo: currentUserId)
        .where('category', isEqualTo: category.name)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TreatmentModel.fromFirestore(doc)).toList());
  }

  Future<String> createTreatment(TreatmentModel treatment) async {
    final docRef = await treatmentsCollection.add({
      ...treatment.toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Future<void> updateTreatment(TreatmentModel treatment) async {
    await treatmentsCollection.doc(treatment.id).update({
      ...treatment.toFirestore(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteTreatment(String treatmentId) async {
    await treatmentsCollection.doc(treatmentId).delete();
  }

  // ==================== APPOINTMENT METHODS ====================

  Stream<List<AppointmentModel>> getAppointments() {
    if (currentUserId == null) return Stream.value([]);
    return appointmentsCollection
        .where('userId', isEqualTo: currentUserId)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => AppointmentModel.fromFirestore(doc)).toList());
  }

  Stream<List<AppointmentModel>> getUpcomingAppointments() {
    if (currentUserId == null) return Stream.value([]);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return appointmentsCollection
        .where('userId', isEqualTo: currentUserId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(today))
        .where('status', isEqualTo: 'scheduled')
        .orderBy('date', descending: false)
        .limit(10)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => AppointmentModel.fromFirestore(doc)).toList());
  }

  Future<String> createAppointment(AppointmentModel appointment) async {
    final docRef = await appointmentsCollection.add({
      ...appointment.toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Future<void> updateAppointment(AppointmentModel appointment) async {
    await appointmentsCollection.doc(appointment.id).update({
      ...appointment.toFirestore(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteAppointment(String appointmentId) async {
    await appointmentsCollection.doc(appointmentId).delete();
  }

  // ==================== STORAGE METHODS ====================

  Reference getStorageRef(String path) => _storage.ref().child(path);

  Future<String> uploadFile({
    required String path,
    required List<int> bytes,
    String? contentType,
  }) async {
    final ref = getStorageRef(path);
    final metadata = contentType != null
        ? SettableMetadata(contentType: contentType)
        : null;
    await ref.putData(bytes, metadata);
    return await ref.getDownloadURL();
  }

  Future<String> uploadFileFromPath({
    required String path,
    required String localPath,
    String? contentType,
  }) async {
    final ref = getStorageRef(path);
    final file = File(localPath);
    final metadata = contentType != null
        ? SettableMetadata(contentType: contentType)
        : null;
    await ref.putFile(file, metadata);
    return await ref.getDownloadURL();
  }

  Future<String> uploadProfilePhoto(
    String patientId,
    String localPath,
  ) async {
    final path = 'users/$currentUserId/patients/$patientId/profile.jpg';
    return await uploadFileFromPath(
      path: path,
      localPath: localPath,
      contentType: 'image/jpeg',
    );
  }

  Future<TreatmentImage> uploadTreatmentImage(
    String patientId,
    String treatmentId,
    String localPath,
    PhotoLabel label,
  ) async {
    final imageId = const Uuid().v4();
    final path = 'users/$currentUserId/patients/$patientId/treatments/$treatmentId/$imageId.jpg';
    
    final url = await uploadFileFromPath(
      path: path,
      localPath: localPath,
      contentType: 'image/jpeg',
    );
    
    return TreatmentImage(
      id: imageId,
      url: url,
      storagePath: path,
      label: label,
      uploadedAt: DateTime.now(),
    );
  }

  Future<void> deleteFile(String path) async {
    final ref = getStorageRef(path);
    await ref.delete();
  }

  // ==================== BACKUP STATUS METHODS ====================

  Future<BackupStatus> getBackupStatus() async {
    if (currentUserId == null) {
      return BackupStatus(id: '');
    }
    
    final doc = await _firestore.collection('backup_status').doc(currentUserId).get();
    if (doc.exists) {
      return BackupStatus.fromFirestore(doc);
    }
    return BackupStatus(id: currentUserId!);
  }

  Future<void> updateBackupStatus(BackupStatus status) async {
    await _firestore.collection('backup_status').doc(status.id).set({
      ...status.toFirestore(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ==================== BATCH & TRANSACTIONS ====================

  WriteBatch batch() => _firestore.batch();

  Future<T> runTransaction<T>(TransactionHandler<T> handler) {
    return _firestore.runTransaction(handler);
  }
}

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});
