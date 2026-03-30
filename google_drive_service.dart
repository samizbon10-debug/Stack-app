import 'dart:io';
import 'dart:typed_data';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import 'firebase_service.dart';

class GoogleDriveService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/drive.file',
      'https://www.googleapis.com/auth/drive.appdata',
    ],
  );

  drive.DriveApi? _driveApi;
  String? _rootFolderId;
  final FirebaseService _firebaseService = FirebaseService();

  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;
  bool get isSignedIn => _googleSignIn.currentUser != null;

  Future<void> initialize() async {
    await _googleSignIn.signInSilently();
    if (_googleSignIn.currentUser != null) {
      await _initializeDriveApi();
    }
  }

  Future<void> signIn() async {
    await _googleSignIn.signIn();
    await _initializeDriveApi();
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _driveApi = null;
    _rootFolderId = null;
  }

  Future<void> _initializeDriveApi() async {
    final googleUser = _googleSignIn.currentUser;
    if (googleUser == null) return;

    final headers = await googleUser.authHeaders;
    final client = GoogleAuthClient(headers);
    _driveApi = drive.DriveApi(client);

    // Ensure root folder exists
    await _ensureRootFolder();
  }

  Future<void> _ensureRootFolder() async {
    if (_driveApi == null) return;

    // Check if "Dental Records" folder exists
    final response = await _driveApi!.files.list(
      q: "name='Dental Records' and mimeType='application/vnd.google-apps.folder' and trashed=false",
      spaces: 'drive',
    );

    if (response.files?.isNotEmpty ?? false) {
      _rootFolderId = response.files!.first.id;
    } else {
      // Create root folder
      final folder = drive.File()
        ..name = 'Dental Records'
        ..mimeType = 'application/vnd.google-apps.folder';
      
      final created = await _driveApi!.files.create(folder);
      _rootFolderId = created.id;
    }
  }

  Future<String?> getRootFolderId() async {
    if (_rootFolderId == null) {
      await _ensureRootFolder();
    }
    return _rootFolderId;
  }

  Future<String?> createPatientFolder(String patientName) async {
    if (_driveApi == null || _rootFolderId == null) return null;

    // Check if patient folder exists
    final response = await _driveApi!.files.list(
      q: "name='$patientName' and parents in '$_rootFolderId' and mimeType='application/vnd.google-apps.folder' and trashed=false",
      spaces: 'drive',
    );

    if (response.files?.isNotEmpty ?? false) {
      return response.files!.first.id;
    }

    // Create patient folder
    final folder = drive.File()
      ..name = patientName
      ..mimeType = 'application/vnd.google-apps.folder'
      ..parents = [_rootFolderId!];
    
    final created = await _driveApi!.files.create(folder);
    return created.id;
  }

  Future<String?> createTreatmentFolder(
    String patientFolderId,
    String treatmentCategory,
    String dateStr,
  ) async {
    if (_driveApi == null) return null;

    // Check if category folder exists
    final categoryResponse = await _driveApi!.files.list(
      q: "name='$treatmentCategory' and parents in '$patientFolderId' and mimeType='application/vnd.google-apps.folder' and trashed=false",
      spaces: 'drive',
    );

    String categoryFolderId;
    if (categoryResponse.files?.isNotEmpty ?? false) {
      categoryFolderId = categoryResponse.files!.first.id!;
    } else {
      // Create category folder
      final folder = drive.File()
        ..name = treatmentCategory
        ..mimeType = 'application/vnd.google-apps.folder'
        ..parents = [patientFolderId];
      
      final created = await _driveApi!.files.create(folder);
      categoryFolderId = created.id!;
    }

    // Check if date folder exists
    final dateResponse = await _driveApi!.files.list(
      q: "name='$dateStr' and parents in '$categoryFolderId' and mimeType='application/vnd.google-apps.folder' and trashed=false",
      spaces: 'drive',
    );

    if (dateResponse.files?.isNotEmpty ?? false) {
      return dateResponse.files!.first.id;
    }

    // Create date folder
    final folder = drive.File()
      ..name = dateStr
      ..mimeType = 'application/vnd.google-apps.folder'
      ..parents = [categoryFolderId];
    
    final created = await _driveApi!.files.create(folder);
    return created.id;
  }

  Future<String?> uploadImageToDrive({
    required String localPath,
    required String patientName,
    required String treatmentCategory,
    required String dateStr,
    required String fileName,
  }) async {
    if (_driveApi == null) return null;

    try {
      // Ensure folder structure
      final patientFolderId = await createPatientFolder(patientName);
      if (patientFolderId == null) return null;

      final treatmentFolderId = await createTreatmentFolder(
        patientFolderId,
        treatmentCategory,
        dateStr,
      );
      if (treatmentFolderId == null) return null;

      // Upload file
      final file = File(localPath);
      if (!await file.exists()) return null;

      final media = drive.Media(file.openRead(), await file.length());
      
      final driveFile = drive.File()
        ..name = fileName
        ..parents = [treatmentFolderId];
      
      final uploaded = await _driveApi!.files.create(
        driveFile,
        uploadMedia: media,
      );

      return uploaded.id;
    } catch (e) {
      print('Error uploading to Drive: $e');
      return null;
    }
  }

  Future<String?> uploadProfilePhoto({
    required String localPath,
    required String patientName,
  }) async {
    if (_driveApi == null) return null;

    try {
      final patientFolderId = await createPatientFolder(patientName);
      if (patientFolderId == null) return null;

      // Create Profile folder
      final profileResponse = await _driveApi!.files.list(
        q: "name='Profile' and parents in '$patientFolderId' and mimeType='application/vnd.google-apps.folder' and trashed=false",
        spaces: 'drive',
      );

      String profileFolderId;
      if (profileResponse.files?.isNotEmpty ?? false) {
        profileFolderId = profileResponse.files!.first.id!;
      } else {
        final folder = drive.File()
          ..name = 'Profile'
          ..mimeType = 'application/vnd.google-apps.folder'
          ..parents = [patientFolderId];
        
        final created = await _driveApi!.files.create(folder);
        profileFolderId = created.id!;
      }

      // Upload profile photo
      final file = File(localPath);
      if (!await file.exists()) return null;

      final media = drive.Media(file.openRead(), await file.length());
      
      final driveFile = drive.File()
        ..name = 'profile_photo.jpg'
        ..parents = [profileFolderId];
      
      final uploaded = await _driveApi!.files.create(
        driveFile,
        uploadMedia: media,
      );

      return uploaded.id;
    } catch (e) {
      print('Error uploading profile photo: $e');
      return null;
    }
  }

  Future<BackupResult> backupAllData() async {
    if (_driveApi == null) {
      return BackupResult(
        success: false,
        message: 'Not signed in to Google Drive',
      );
    }

    try {
      // Update backup status to in_progress
      await _firebaseService.updateBackupStatus(
        BackupStatus(
          id: _firebaseService.currentUserId!,
          backupStatus: 'in_progress',
        ),
      );

      int recordsBackedUp = 0;
      int imagesBackedUp = 0;

      // Get all patients
      final patients = await _firebaseService.getPatientsOnce();
      
      for (final patient in patients) {
        // Get all treatments for patient
        final treatments = await _firebaseService.getTreatmentsOnce(patient.id);
        
        for (final treatment in treatments) {
          final dateStr = _formatDate(treatment.date);
          
          for (final image in treatment.images) {
            // Download image from Firebase Storage
            final imageFile = await _downloadImageFromUrl(image.url);
            if (imageFile != null) {
              final driveFileId = await uploadImageToDrive(
                localPath: imageFile.path,
                patientName: patient.name,
                treatmentCategory: treatment.category.folderName,
                dateStr: dateStr,
                fileName: '${image.labelDisplay}_${image.id}.jpg',
              );
              
              if (driveFileId != null) {
                imagesBackedUp++;
              }
              
              // Clean up temp file
              await imageFile.delete();
            }
          }
          recordsBackedUp++;
        }
      }

      // Update backup status to success
      await _firebaseService.updateBackupStatus(
        BackupStatus(
          id: _firebaseService.currentUserId!,
          lastBackupTime: DateTime.now(),
          backupStatus: 'success',
          totalRecordsBackedUp: recordsBackedUp,
          totalImagesBackedUp: imagesBackedUp,
          driveFolderId: _rootFolderId,
        ),
      );

      return BackupResult(
        success: true,
        message: 'Backup completed successfully',
        recordsBackedUp: recordsBackedUp,
        imagesBackedUp: imagesBackedUp,
      );
    } catch (e) {
      // Update backup status to failed
      await _firebaseService.updateBackupStatus(
        BackupStatus(
          id: _firebaseService.currentUserId!,
          backupStatus: 'failed',
          errorMessage: e.toString(),
        ),
      );

      return BackupResult(
        success: false,
        message: 'Backup failed: $e',
      );
    }
  }

  Future<File?> _downloadImageFromUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final tempDir = Directory.systemTemp;
        final file = File('${tempDir.path}/temp_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await file.writeAsBytes(response.bodyBytes);
        return file;
      }
    } catch (e) {
      print('Error downloading image: $e');
    }
    return null;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class BackupResult {
  final bool success;
  final String message;
  final int recordsBackedUp;
  final int imagesBackedUp;

  BackupResult({
    required this.success,
    required this.message,
    this.recordsBackedUp = 0,
    this.imagesBackedUp = 0,
  });
}

// Custom HTTP client for Google authentication
class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}
