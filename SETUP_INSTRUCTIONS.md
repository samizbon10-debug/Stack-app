# Dental Case Manager - Setup Instructions

## Complete Firebase & Google Drive Setup Guide

This guide will walk you through setting up Firebase and Google Drive API for the Dental Case Manager app.

---

## Part 1: Firebase Project Setup

### Step 1: Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or "Create a project"
3. Enter project name: `Dental Case Manager` (or your preferred name)
4. Disable Google Analytics (optional for this project)
5. Click "Create project"

### Step 2: Enable Firebase Services

In your Firebase Console, navigate to each service and enable them:

#### Authentication
1. Go to **Build > Authentication**
2. Click "Get started"
3. Enable **Google** sign-in provider
4. Add your support email
5. Click "Save"

#### Cloud Firestore
1. Go to **Build > Firestore Database**
2. Click "Create database"
3. Select "Start in test mode" (we'll add security rules later)
4. Choose your preferred region
5. Click "Enable"

#### Storage
1. Go to **Build > Storage**
2. Click "Get started"
3. Select "Start in test mode"
4. Choose your preferred region
5. Click "Done"

---

## Part 2: Add Android App

### Step 1: Register Android App

1. In Firebase Console, click the Android icon to add an app
2. Enter package name: `com.dental.case_manager`
3. Enter app nickname: `Dental Case Manager`
4. Enter SHA-1 certificate fingerprint (for Google Sign-In):
   ```bash
   # Debug certificate
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
   Copy the SHA-1 value
5. Click "Register app"

### Step 2: Download google-services.json

1. Download `google-services.json`
2. Place it in your Flutter project at:
   ```
   dental_case_manager/android/app/google-services.json
   ```

### Step 3: Add Google Services Classpath

Edit `android/build.gradle`:
```gradle
dependencies {
    classpath 'com.android.tools.build:gradle:7.4.2'
    classpath 'com.google.gms:google-services:4.3.15' // Add this line
}
```

Edit `android/app/build.gradle`:
```gradle
apply plugin: 'com.android.application'
apply plugin: 'com.google.gms.google-services' // Add this line

dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    // ... other dependencies
}
```

---

## Part 3: Add iOS App

### Step 1: Register iOS App

1. In Firebase Console, click the iOS icon to add an app
2. Enter bundle ID: `com.dental.caseManager`
3. Enter app nickname: `Dental Case Manager`
4. Click "Register app"

### Step 2: Download GoogleService-Info.plist

1. Download `GoogleService-Info.plist`
2. Place it in your Flutter project at:
   ```
   dental_case_manager/ios/Runner/GoogleService-Info.plist
   ```

### Step 3: Configure iOS Project

Open `ios/Runner/Info.plist` and add:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>YOUR_REVERSED_CLIENT_ID</string>
        </array>
    </dict>
</array>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to photos for patient records</string>
<key>NSCameraUsageDescription</key>
<string>This app needs camera access for clinical photos</string>
<key>NSFaceIDUsageDescription</key>
<string>This app uses Face ID for secure access</string>
```

Replace `YOUR_REVERSED_CLIENT_ID` with the value from your GoogleService-Info.plist.

---

## Part 4: Google Drive API Setup

### Step 1: Enable Google Drive API

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your Firebase project
3. Go to **APIs & Services > Library**
4. Search for "Google Drive API"
5. Click "Enable"

### Step 2: Configure OAuth Consent Screen

1. Go to **APIs & Services > OAuth consent screen**
2. Select "External" user type (or "Internal" if using Google Workspace)
3. Fill in required fields:
   - App name: `Dental Case Manager`
   - User support email: your email
   - Developer contact: your email
4. Click "Save and Continue"
5. Add scopes:
   - `https://www.googleapis.com/auth/drive.file`
   - `https://www.googleapis.com/auth/userinfo.email`
   - `https://www.googleapis.com/auth/userinfo.profile`
6. Click "Save and Continue"
7. Add test users (your email)
8. Click "Save and Continue"

### Step 3: Create OAuth 2.0 Credentials

1. Go to **APIs & Services > Credentials**
2. Click "Create Credentials > OAuth client ID"
3. Select "Android" for Android app or "iOS" for iOS app
4. For Android:
   - Package name: `com.dental.case_manager`
   - SHA-1: (same as from Firebase setup)
5. Click "Create"

---

## Part 5: Firestore Security Rules

Go to Firebase Console > Firestore > Rules and add:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own data
    match /patients/{patientId} {
      allow read, write: if request.auth != null && 
        request.resource.data.userId == request.auth.uid;
    }
    
    match /treatments/{treatmentId} {
      allow read, write: if request.auth != null && 
        request.resource.data.userId == request.auth.uid;
    }
    
    match /appointments/{appointmentId} {
      allow read, write: if request.auth != null && 
        request.resource.data.userId == request.auth.uid;
    }
    
    match /backup_status/{statusId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == statusId;
    }
    
    match /users/{userId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == userId;
    }
  }
}
```

---

## Part 6: Storage Security Rules

Go to Firebase Console > Storage > Rules and add:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && 
        request.auth.uid == userId;
    }
  }
}
```

---

## Part 7: Generate Firebase Options File

Run FlutterFire CLI to generate the configuration file:

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Login to Firebase
flutterfire login

# Configure project
flutterfire configure --project=YOUR_PROJECT_ID
```

This will generate `lib/firebase_options.dart` with your actual configuration values.

---

## Part 8: Build and Run

### Prerequisites

1. Install Flutter SDK: https://docs.flutter.dev/get-started/install
2. Install Android Studio or Xcode
3. Set up an Android emulator or iOS simulator

### Commands

```bash
# Navigate to project directory
cd dental_case_manager

# Get dependencies
flutter pub get

# Run on Android
flutter run

# Run on iOS (macOS only)
flutter run -d ios

# Build APK
flutter build apk --release

# Build iOS (macOS only)
flutter build ios --release
```

---

## Part 9: Project Structure

```
dental_case_manager/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── firebase_options.dart     # Firebase configuration
│   ├── models/                   # Data models
│   │   ├── patient_model.dart
│   │   ├── treatment_model.dart
│   │   ├── appointment_model.dart
│   │   └── user_model.dart
│   ├── services/                 # Business logic
│   │   ├── firebase_service.dart
│   │   ├── auth_service.dart
│   │   ├── google_drive_service.dart
│   │   ├── cache_service.dart
│   │   └── notification_service.dart
│   ├── providers/                # State management
│   │   └── providers.dart
│   ├── screens/                  # UI screens
│   │   ├── splash_screen.dart
│   │   ├── auth_screen.dart
│   │   ├── lock_screen.dart
│   │   ├── home_screen.dart
│   │   ├── patients_screen.dart
│   │   ├── patient_detail_screen.dart
│   │   ├── add_patient_screen.dart
│   │   ├── treatments_screen.dart
│   │   ├── add_treatment_screen.dart
│   │   ├── appointments_screen.dart
│   │   ├── case_gallery_screen.dart
│   │   └── settings_screen.dart
│   ├── widgets/                  # Reusable widgets
│   │   ├── dashboard_card.dart
│   │   ├── patient_card.dart
│   │   ├── treatment_card.dart
│   │   ├── search_bar_widget.dart
│   │   ├── upcoming_appointments_card.dart
│   │   └── backup_status_card.dart
│   ├── theme/                    # App theme
│   │   └── app_theme.dart
│   ├── animations/               # Animation utilities
│   │   └── app_animations.dart
│   └── utils/                    # Utility functions
├── android/                      # Android configuration
├── ios/                          # iOS configuration
├── pubspec.yaml                  # Dependencies
└── README.md                     # Project documentation
```

---

## Troubleshooting

### Common Issues

1. **Google Sign-In not working on Android**
   - Ensure SHA-1 certificate is added in Firebase Console
   - Verify `google-services.json` is in the correct location
   - Check that the package name matches exactly

2. **iOS Google Sign-In issues**
   - Verify `GoogleService-Info.plist` is added to the project
   - Check URL schemes in Info.plist
   - Ensure the bundle ID matches

3. **Firestore permission denied**
   - Check security rules
   - Ensure user is authenticated
   - Verify userId matches

4. **Storage upload failed**
   - Check storage rules
   - Ensure Firebase Storage is enabled
   - Verify file size limits

5. **Google Drive backup not working**
   - Verify Google Drive API is enabled
   - Check OAuth consent screen configuration
   - Ensure required scopes are granted

---

## Support

For issues or questions:
1. Check Firebase documentation: https://firebase.google.com/docs
2. Flutter documentation: https://docs.flutter.dev
3. Google Drive API documentation: https://developers.google.com/drive

---

## License

This project is for educational and clinical use. Ensure compliance with local healthcare data regulations (HIPAA, GDPR, etc.) when handling patient data.
