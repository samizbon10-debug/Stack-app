import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import 'google_drive_service.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get firebaseUser => _firebaseAuth.currentUser;
  String? get currentUserId => _firebaseAuth.currentUser?.uid;
  bool get isAuthenticated => _firebaseAuth.currentUser != null;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<AuthResult> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return AuthResult(success: false, message: 'Sign in cancelled');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = 
          await _firebaseAuth.signInWithCredential(credential);
      
      final User? user = userCredential.user;
      
      if (user == null) {
        return AuthResult(success: false, message: 'Failed to sign in');
      }

      // Check if user exists in Firestore, create if not
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      if (!userDoc.exists) {
        final newUser = UserModel(
          id: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? 'Dentist',
          photoUrl: user.photoURL,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          settings: UserSettings(),
        );
        await _firestore.collection('users').doc(user.uid).set(newUser.toFirestore());
      } else {
        // Update last login
        await _firestore.collection('users').doc(user.uid).update({
          'lastLoginAt': Timestamp.fromDate(DateTime.now()),
        });
      }

      return AuthResult(
        success: true,
        message: 'Sign in successful',
        user: user,
      );
    } catch (e) {
      return AuthResult(success: false, message: 'Error: $e');
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }

  // ==================== PIN LOCK ====================

  Future<void> setPin(String pin) async {
    final hashedPin = _hashPin(pin);
    await _secureStorage.write(key: 'app_pin', value: hashedPin);
    
    // Also update in Firestore
    if (currentUserId != null) {
      await _firestore.collection('users').doc(currentUserId).update({
        'pinHash': hashedPin,
      });
    }
  }

  Future<bool> verifyPin(String pin) async {
    final storedHash = await _secureStorage.read(key: 'app_pin');
    if (storedHash == null) return false;
    
    return storedHash == _hashPin(pin);
  }

  Future<bool> hasPinLock() async {
    final storedPin = await _secureStorage.read(key: 'app_pin');
    return storedPin != null && storedPin.isNotEmpty;
  }

  Future<void> removePinLock() async {
    await _secureStorage.delete(key: 'app_pin');
    
    if (currentUserId != null) {
      await _firestore.collection('users').doc(currentUserId).update({
        'pinHash': null,
      });
    }
  }

  String _hashPin(String pin) {
    // Simple hash for demo - in production use proper crypto
    return pin.hashCode.toString();
  }

  // ==================== BIOMETRIC AUTH ====================

  Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access Dental Case Manager',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _secureStorage.write(
      key: 'biometric_enabled',
      value: enabled.toString(),
    );
    
    if (currentUserId != null) {
      await _firestore.collection('users').doc(currentUserId).update({
        'biometricEnabled': enabled,
      });
    }
  }

  Future<bool> isBiometricEnabled() async {
    final value = await _secureStorage.read(key: 'biometric_enabled');
    return value == 'true';
  }

  // ==================== USER DATA ====================

  Future<UserModel?> getCurrentUserData() async {
    if (currentUserId == null) return null;
    
    final doc = await _firestore.collection('users').doc(currentUserId).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  Future<void> updateUserSettings(UserSettings settings) async {
    if (currentUserId == null) return;
    
    await _firestore.collection('users').doc(currentUserId).update({
      'settings': settings.toMap(),
    });
  }
}

class AuthResult {
  final bool success;
  final String message;
  final User? user;

  AuthResult({
    required this.success,
    required this.message,
    this.user,
  });
}
