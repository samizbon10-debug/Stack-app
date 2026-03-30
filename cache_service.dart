import 'dart:convert';
import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/models.dart';

class CacheService {
  static const String _patientsBox = 'patients_cache';
  static const String _treatmentsBox = 'treatments_cache';
  static const String _appointmentsBox = 'appointments_cache';
  static const String _imagesBox = 'images_cache';

  late Box<Map> _patients;
  late Box<Map> _treatments;
  late Box<Map> _appointments;
  late Box<String> _imagePaths;

  String? _cacheDirectory;

  Future<void> initialize() async {
    await Hive.initFlutter();
    
    _patients = await Hive.openBox<Map>(_patientsBox);
    _treatments = await Hive.openBox<Map>(_treatmentsBox);
    _appointments = await Hive.openBox<Map>(_appointmentsBox);
    _imagePaths = await Hive.openBox<String>(_imagesBox);

    final appDir = await getApplicationDocumentsDirectory();
    _cacheDirectory = '${appDir.path}/dental_cache';
    
    final dir = Directory(_cacheDirectory!);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  // ==================== PATIENTS CACHE ====================

  Future<void> cachePatients(List<PatientModel> patients) async {
    await _patients.clear();
    for (final patient in patients) {
      await _patients.put(patient.id, patient.toFirestore());
    }
  }

  Future<void> cachePatient(PatientModel patient) async {
    await _patients.put(patient.id, patient.toFirestore());
  }

  Future<void> removeCachedPatient(String patientId) async {
    await _patients.delete(patientId);
  }

  List<PatientModel> getCachedPatients() {
    return _patients.values
        .map((data) => PatientModel.fromFirestore(
            _MockDocumentSnapshot(data.cast<String, dynamic>())))
        .toList();
  }

  PatientModel? getCachedPatient(String patientId) {
    final data = _patients.get(patientId);
    if (data != null) {
      return PatientModel.fromFirestore(
          _MockDocumentSnapshot(data.cast<String, dynamic>()));
    }
    return null;
  }

  // ==================== TREATMENTS CACHE ====================

  Future<void> cacheTreatments(String patientId, List<TreatmentModel> treatments) async {
    final key = 'patient_$patientId';
    await _treatments.put(key, {
      'treatments': treatments.map((t) => t.toFirestore()).toList(),
      'cachedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> cacheTreatment(TreatmentModel treatment) async {
    await _treatments.put(treatment.id, treatment.toFirestore());
  }

  Future<void> removeCachedTreatment(String treatmentId) async {
    await _treatments.delete(treatmentId);
  }

  List<TreatmentModel> getCachedTreatments(String patientId) {
    final key = 'patient_$patientId';
    final data = _treatments.get(key);
    if (data != null && data['treatments'] != null) {
      return (data['treatments'] as List)
          .map((t) => TreatmentModel.fromFirestore(
              _MockDocumentSnapshot(t.cast<String, dynamic>())))
          .toList();
    }
    return [];
  }

  TreatmentModel? getCachedTreatment(String treatmentId) {
    final data = _treatments.get(treatmentId);
    if (data != null) {
      return TreatmentModel.fromFirestore(
          _MockDocumentSnapshot(data.cast<String, dynamic>()));
    }
    return null;
  }

  // ==================== APPOINTMENTS CACHE ====================

  Future<void> cacheAppointments(List<AppointmentModel> appointments) async {
    await _appointments.clear();
    for (final appointment in appointments) {
      await _appointments.put(appointment.id, appointment.toFirestore());
    }
  }

  Future<void> cacheAppointment(AppointmentModel appointment) async {
    await _appointments.put(appointment.id, appointment.toFirestore());
  }

  Future<void> removeCachedAppointment(String appointmentId) async {
    await _appointments.delete(appointmentId);
  }

  List<AppointmentModel> getCachedAppointments() {
    return _appointments.values
        .map((data) => AppointmentModel.fromFirestore(
            _MockDocumentSnapshot(data.cast<String, dynamic>())))
        .toList();
  }

  // ==================== IMAGE CACHE ====================

  Future<String?> cacheImage(String url, String imageId) async {
    try {
      // Check if already cached
      final cachedPath = _imagePaths.get(imageId);
      if (cachedPath != null && await File(cachedPath).exists()) {
        return cachedPath;
      }

      // Download and cache
      final httpClient = HttpClient();
      final request = await httpClient.getUrl(Uri.parse(url));
      final response = await request.close();
      
      final bytes = await consolidateHttpClientResponseBytes(response);
      
      final filePath = '$_cacheDirectory/$imageId.jpg';
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      
      await _imagePaths.put(imageId, filePath);
      
      return filePath;
    } catch (e) {
      print('Error caching image: $e');
      return null;
    }
  }

  Future<String?> getCachedImagePath(String imageId) async {
    final path = _imagePaths.get(imageId);
    if (path != null && await File(path).exists()) {
      return path;
    }
    return null;
  }

  Future<void> clearImageCache() async {
    await _imagePaths.clear();
    if (_cacheDirectory != null) {
      final dir = Directory(_cacheDirectory!);
      if (await dir.exists()) {
        await for (final entity in dir.list()) {
          if (entity is File) {
            await entity.delete();
          }
        }
      }
    }
  }

  // ==================== GENERAL CACHE ====================

  Future<void> clearAllCache() async {
    await _patients.clear();
    await _treatments.clear();
    await _appointments.clear();
    await clearImageCache();
  }

  Future<void> setLastSyncTime(DateTime time) async {
    final box = await Hive.openBox('settings');
    await box.put('lastSyncTime', time.toIso8601String());
  }

  Future<DateTime?> getLastSyncTime() async {
    final box = await Hive.openBox('settings');
    final timeStr = box.get('lastSyncTime') as String?;
    if (timeStr != null) {
      return DateTime.parse(timeStr);
    }
    return null;
  }
}

// Helper class to simulate Firestore DocumentSnapshot
class _MockDocumentSnapshot implements DocumentSnapshot {
  final Map<String, dynamic> _data;
  
  _MockDocumentSnapshot(this._data);
  
  @override
  String get id => _data['id'] ?? '';
  
  @override
  Map<String, dynamic>? data() => _data;
  
  @override
  bool get exists => _data.isNotEmpty;
  
  @override
  dynamic get(Object field) => _data[field];
  
  @override
  SnapshotMetadata get metadata => throw UnimplementedError();
  
  @override
  DocumentReference get reference => throw UnimplementedError();
}

// Helper to consolidate bytes
Future<Uint8List> consolidateHttpClientResponseBytes(HttpClientResponse response) async {
  final completer = Completer<Uint8List>();
  final chunks = <Uint8List>[];
  int totalSize = 0;

  response.listen(
    (chunk) {
      chunks.add(chunk);
      totalSize += chunk.length;
    },
    onDone: () {
      final result = Uint8List(totalSize);
      int offset = 0;
      for (final chunk in chunks) {
        result.setRange(offset, offset + chunk.length, chunk);
        offset += chunk.length;
      }
      completer.complete(result);
    },
    onError: (error) => completer.completeError(error),
  );

  return completer.future;
}

import 'dart:async';
import 'package:flutter/foundation.dart';
