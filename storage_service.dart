import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  /// Upload patient profile photo
  Future<String> uploadProfilePhoto({
    required String userId,
    required String patientId,
    required String filePath,
  }) async {
    final file = File(filePath);
    final fileName = 'profile_${_uuid.v4()}.jpg';
    final ref = _storage.ref()
        .child('users')
        .child(userId)
        .child('patients')
        .child(patientId)
        .child('profile')
        .child(fileName);

    final uploadTask = ref.putFile(
      file,
      SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'userId': userId,
          'patientId': patientId,
          'type': 'profile',
        },
      ),
    );

    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  /// Upload treatment image
  Future<String> uploadTreatmentImage({
    required String userId,
    required String patientId,
    required String treatmentId,
    required String label, // before, during, after
    required String filePath,
  }) async {
    final file = File(filePath);
    final fileName = '${label}_${_uuid.v4()}.jpg';
    final ref = _storage.ref()
        .child('users')
        .child(userId)
        .child('patients')
        .child(patientId)
        .child('treatments')
        .child(treatmentId)
        .child(label)
        .child(fileName);

    final uploadTask = ref.putFile(
      file,
      SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'userId': userId,
          'patientId': patientId,
          'treatmentId': treatmentId,
          'label': label,
        },
      ),
    );

    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  /// Delete image from storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      // Image may not exist, ignore error
    }
  }

  /// Get thumbnail URL (if available)
  String? getThumbnailUrl(String imageUrl, {int size = 200}) {
    // Firebase Storage doesn't auto-generate thumbnails
    // You would need to use Firebase Extensions or Cloud Functions
    // For now, return the original URL
    return imageUrl;
  }

  /// List all images for a patient
  Future<List<String>> listPatientImages({
    required String userId,
    required String patientId,
  }) async {
    final ref = _storage.ref()
        .child('users')
        .child(userId)
        .child('patients')
        .child(patientId);

    final result = await ref.listAll();
    final urls = <String>[];

    for (final item in result.items) {
      final url = await item.getDownloadURL();
      urls.add(url);
    }

    return urls;
  }

  /// List all treatment images
  Future<List<String>> listTreatmentImages({
    required String userId,
    required String patientId,
    required String treatmentId,
  }) async {
    final ref = _storage.ref()
        .child('users')
        .child(userId)
        .child('patients')
        .child(patientId)
        .child('treatments')
        .child(treatmentId);

    final result = await ref.listAll();
    final urls = <String>[];

    for (final item in result.items) {
      final url = await item.getDownloadURL();
      urls.add(url);
    }

    return urls;
  }

  /// Get storage usage for user
  Future<int> getUserStorageUsage(String userId) async {
    final ref = _storage.ref().child('users').child(userId);
    final result = await ref.listAll();
    
    int totalSize = 0;
    for (final item in result.items) {
      final metadata = await item.getMetadata();
      totalSize += metadata.size ?? 0;
    }
    
    return totalSize;
  }
}
