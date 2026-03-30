# Dental Case Manager 🦷

A comprehensive Flutter mobile application for dentists to manage patient records, treatment histories, and clinical photos with automatic Google Drive backup.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![Firebase](https://img.shields.io/badge/Firebase-Latest-orange.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## Features ✨

### Patient Management
- **Complete Patient Profiles**: Name, phone, age, gender, medical history, allergies, smoking status
- **Profile Photos**: Capture or upload patient photos
- **Quick Search**: Search patients by name or phone number
- **Treatment History**: View all treatments for each patient

### Treatment Records
- **Three Treatment Categories**:
  - Orthodontics
  - Fillings
  - Scaling & Polishing
- **Detailed Records**: Diagnosis, tooth number, materials used, progress notes
- **Clinical Photos**: Before, During, and After photo labels

### Photo Management
- **Multi-Photo Upload**: Add multiple photos per treatment
- **Photo Labels**: Organize photos as Before/During/After
- **Case Gallery**: View all cases with before/after comparison slider
- **Full-Screen Viewing**: Zoom and pan clinical photos

### Appointments
- **Calendar View**: Visual calendar with appointment markers
- **Appointment Details**: Patient, treatment type, time, notes
- **Reminders**: Local notifications for upcoming appointments
- **Status Tracking**: Scheduled, Completed, Cancelled

### Security
- **Google Sign-In**: Secure authentication
- **PIN Lock**: Optional 4-digit PIN protection
- **Biometric Authentication**: Fingerprint/Face ID support
- **Encrypted Storage**: Secure local data storage
- **Firebase Security Rules**: Server-side data protection

### Backup & Sync
- **Automatic Google Drive Backup**: All data backed up automatically
- **Organized Folder Structure**: Patient-specific folders
- **Backup Status**: Track last backup time and status
- **Offline Support**: View cached records without internet

### UI/UX
- **Modern Design**: Clean, professional dental-clinic friendly interface
- **Smooth Animations**: Hero animations, slide transitions, fade effects
- **Responsive Layout**: Optimized for various screen sizes
- **Large Touch Targets**: Easy to use during clinical workflow

## Technology Stack 🛠️

| Category | Technology |
|----------|------------|
| Frontend | Flutter 3.0+ |
| Backend | Firebase |
| Database | Cloud Firestore |
| Storage | Firebase Storage |
| Auth | Google Sign-In |
| Backup | Google Drive API |
| State Management | Riverpod |
| Animations | flutter_animate |
| Local Storage | Hive + Flutter Secure Storage |

## Getting Started 🚀

### Prerequisites
- Flutter SDK 3.0 or higher
- Android Studio / Xcode
- Firebase account
- Google Cloud project

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/dental_case_manager.git
   cd dental_case_manager
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Firebase**
   - Follow detailed instructions in [SETUP_INSTRUCTIONS.md](SETUP_INSTRUCTIONS.md)
   - Create Firebase project
   - Add Android and iOS apps
   - Download configuration files
   - Enable Google Drive API

4. **Run the app**
   ```bash
   flutter run
   ```

### Build for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS (macOS only)
flutter build ios --release
```

## Project Structure 📁

```
lib/
├── main.dart                    # App entry point
├── firebase_options.dart        # Firebase configuration
├── models/                      # Data models
│   ├── patient_model.dart
│   ├── treatment_model.dart
│   ├── appointment_model.dart
│   └── user_model.dart
├── services/                    # Business logic services
│   ├── firebase_service.dart
│   ├── auth_service.dart
│   ├── google_drive_service.dart
│   ├── cache_service.dart
│   └── notification_service.dart
├── providers/                   # Riverpod state management
├── screens/                     # UI screens (14 screens)
├── widgets/                     # Reusable components
├── theme/                       # App theming
├── animations/                  # Animation utilities
└── utils/                       # Helper functions
```

## Database Schema 📊

### Collections

#### patients
```json
{
  "id": "string",
  "name": "string",
  "phone": "string",
  "age": "number",
  "gender": "string",
  "medicalHistory": "string",
  "allergies": ["string"],
  "smokingStatus": "boolean",
  "profilePhotoUrl": "string",
  "userId": "string"
}
```

#### treatments
```json
{
  "id": "string",
  "patientId": "string",
  "category": "orthodontics|fillings|scalingPolishing",
  "toothNumber": "string",
  "date": "timestamp",
  "diagnosis": "string",
  "treatmentNotes": "string",
  "materialsUsed": ["string"],
  "images": [{ "url", "label", "storagePath" }]
}
```

#### appointments
```json
{
  "id": "string",
  "patientId": "string",
  "patientName": "string",
  "date": "timestamp",
  "time": "string",
  "treatmentType": "string",
  "status": "scheduled|completed|cancelled"
}
```

## Clinical Workflow 💼

The app is optimized for fast clinical use:

1. **Open app** → Auto-unlock with biometrics
2. **Search patient** → Quick search from home
3. **View/Add treatment** → Minimal taps
4. **Take photo** → Camera directly accessible
5. **Save** → Auto-backup to Google Drive

## Security & Privacy 🔒

- **HIPAA Considerations**: Designed with healthcare data privacy in mind
- **Local Encryption**: Sensitive data encrypted using Flutter Secure Storage
- **Server-Side Security**: Firebase Security Rules ensure data isolation
- **Authentication Required**: All data access requires valid authentication
- **Secure Backup**: Google Drive with user's own account

## Performance 📱

- **Lazy Loading**: Images loaded on demand
- **Caching**: Offline access to cached records
- **Optimized Animations**: 60fps smooth transitions
- **Efficient Queries**: Indexed Firestore queries

## Screenshots 📸

| Home Dashboard | Patient List | Patient Detail |
|----------------|--------------|----------------|
| ![Home](screenshots/home.png) | ![Patients](screenshots/patients.png) | ![Detail](screenshots/detail.png) |

| Treatment Form | Case Gallery | Before/After |
|----------------|--------------|--------------|
| ![Treatment](screenshots/treatment.png) | ![Gallery](screenshots/gallery.png) | ![Compare](screenshots/compare.png) |

## Contributing 🤝

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License 📄

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support 💬

For support, please open an issue on GitHub or contact the development team.

## Acknowledgments 🙏

- Flutter Team for the amazing framework
- Firebase for backend services
- Google for Drive API access
- All contributors and testers

---

**Note**: This application handles sensitive patient data. Ensure compliance with local healthcare data protection regulations (HIPAA, GDPR, etc.) before deploying in a clinical environment.
