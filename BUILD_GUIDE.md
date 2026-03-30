# 🏗️ Dental Case Manager - Build Guide

## ⚠️ IMPORTANT: Requirements

This is a **Flutter mobile application** that requires a local development environment with Flutter SDK installed. APK cannot be built directly on this server.

### Prerequisites for Building APK

1. **Flutter SDK** (3.0 or higher)
   - Download from: https://docs.flutter.dev/get-started/install
   - Verify installation: `flutter doctor`

2. **Android Studio** or **Android SDK**
   - Install Android SDK 34
   - Set up Android emulator or connect physical device

3. **Java JDK 17**
   - Required for Android build

4. **Firebase Account**
   - Create a Firebase project
   - Add Android app with package name: `com.dental.case_manager`

---

## 🚀 Quick Build Instructions

### Step 1: Install Flutter
```bash
# Windows
https://docs.flutter.dev/get-started/install/windows

# macOS
https://docs.flutter.dev/get-started/install/macos

# Linux
https://docs.flutter.dev/get-started/install/linux
```

### Step 2: Clone/Copy Project
```bash
# Copy the project to your local machine
# Or extract from the downloaded archive
cd dental_case_manager
```

### Step 3: Install Dependencies
```bash
flutter pub get
```

### Step 4: Configure Firebase

#### 4.1 Create Firebase Project
1. Go to https://console.firebase.google.com/
2. Click "Add project"
3. Enter project name: "Dental Case Manager"
4. Disable Google Analytics (optional)
5. Click "Create project"

#### 4.2 Add Android App
1. In Firebase Console, click Android icon
2. Package name: `com.dental.case_manager`
3. App nickname: "Dental Case Manager"
4. Get SHA-1 certificate:
   ```bash
   # Debug certificate
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
5. Click "Register app"

#### 4.3 Download google-services.json
1. Download `google-services.json`
2. Replace the placeholder at:
   ```
   android/app/google-services.json
   ```

#### 4.4 Enable Firebase Services
In Firebase Console:
- **Authentication** → Enable Google Sign-In
- **Firestore Database** → Create database (start in test mode)
- **Storage** → Get started (start in test mode)

#### 4.5 Enable Google Drive API
1. Go to Google Cloud Console
2. Select your Firebase project
3. APIs & Services → Library
4. Search "Google Drive API" → Enable

#### 4.6 Generate Firebase Options
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Login to Firebase
flutterfire login

# Configure project
flutterfire configure --project=YOUR_PROJECT_ID
```

### Step 5: Build APK

#### Debug APK
```bash
flutter build apk --debug
```
Output: `build/app/outputs/flutter-apk/app-debug.apk`

#### Release APK
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

#### App Bundle (for Play Store)
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

---

## 📱 Run on Device

### With Emulator
```bash
# List available emulators
flutter emulators

# Launch emulator
flutter emulators --launch <emulator_id>

# Run app
flutter run
```

### With Physical Device
1. Enable Developer Options on your Android device
2. Enable USB Debugging
3. Connect device via USB
4. Run:
```bash
flutter devices
flutter run
```

---

## 🔧 Troubleshooting

### Common Build Errors

#### 1. "google-services.json not found"
- Ensure `google-services.json` is in `android/app/`
- Verify the file is not empty

#### 2. "SDK location not found"
Create `android/local.properties`:
```properties
sdk.path=/path/to/Android/sdk
flutter.sdk=/path/to/flutter
```

#### 3. "Gradle build failed"
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk
```

#### 4. "Keystore not found"
For release builds, you need a signing keystore:
```bash
keytool -genkey -v -keystore dental-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias dental-key
```

Then create `android/key.properties`:
```properties
storePassword=YOUR_PASSWORD
keyPassword=YOUR_PASSWORD
keyAlias=dental-key
storeFile=../dental-keystore.jks
```

---

## 📋 Build Checklist

- [ ] Flutter SDK installed (`flutter doctor` passes)
- [ ] Android SDK installed
- [ ] Firebase project created
- [ ] `google-services.json` added to `android/app/`
- [ ] Firebase Authentication enabled (Google Sign-In)
- [ ] Firestore Database created
- [ ] Firebase Storage enabled
- [ ] Google Drive API enabled
- [ ] Dependencies installed (`flutter pub get`)
- [ ] Build successful (`flutter build apk`)

---

## 🏃 Fast Build Commands

```bash
# Clean everything
flutter clean && flutter pub get

# Build debug APK (faster)
flutter build apk --debug

# Build release APK (optimized)
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols

# Install on connected device
flutter install
```

---

## 📦 Output Files

After successful build:
```
build/app/outputs/
├── flutter-apk/
│   ├── app-debug.apk         # Debug build
│   └── app-release.apk       # Release build
├── bundle/
│   └── release/
│       └── app-release.aab   # App Bundle for Play Store
└── symbols/                   # Debug symbols (if obfuscated)
```

---

## 🔐 Security Notes

1. **Never commit** `google-services.json` to public repositories
2. Use environment variables for sensitive keys
3. Create release keystore for production builds
4. Enable ProGuard for code obfuscation (already configured)

---

## 📞 Support

If you encounter issues:
1. Run `flutter doctor -v` and fix any issues
2. Check Firebase Console for configuration errors
3. Ensure all APIs are enabled in Google Cloud Console

---

**Ready to build? Follow the steps above and you'll have your APK in minutes!** 🎉
