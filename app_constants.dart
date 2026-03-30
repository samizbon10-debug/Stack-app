/// Application-wide constants
class AppConstants {
  // App Info
  static const String appName = 'Dental Case Manager';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Professional Dental Patient Record System';

  // Storage Keys
  static const String userBoxKey = 'user_data';
  static const String patientsBoxKey = 'patients_cache';
  static const String treatmentsBoxKey = 'treatments_cache';
  static const String appointmentsBoxKey = 'appointments_cache';
  static const String settingsBoxKey = 'settings';
  static const String offlineQueueKey = 'offline_queue';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String patientsCollection = 'patients';
  static const String treatmentsCollection = 'treatments';
  static const String appointmentsCollection = 'appointments';
  static const String galleryCollection = 'gallery';
  static const String backupLogsCollection = 'backup_logs';
  static const String offlineQueueCollection = 'offline_queue';

  // Google Drive
  static const String driveFolderName = 'Dental Records';
  static const String profileFolderName = 'Profile';
  static const String orthodonticsFolderName = 'Orthodontics';
  static const String fillingsFolderName = 'Fillings';
  static const String scalingFolderName = 'Scaling & Polishing';

  // Treatment Categories
  static const String orthodontics = 'orthodontics';
  static const String fillings = 'fillings';
  static const String scalingPolishing = 'scaling_polishing';

  // Photo Labels
  static const String photoBefore = 'before';
  static const String photoDuring = 'during';
  static const String photoAfter = 'after';

  // Appointment Status
  static const String scheduled = 'scheduled';
  static const String confirmed = 'confirmed';
  static const String completed = 'completed';
  static const String cancelled = 'cancelled';

  // Treatment Status
  static const String planned = 'planned';
  static const String inProgress = 'in_progress';
  static const String treatmentCompleted = 'completed';

  // Smoking Status
  static const String neverSmoked = 'never';
  static const String formerSmoker = 'former';
  static const String currentSmoker = 'current';

  // Gender
  static const String male = 'male';
  static const String female = 'female';
  static const String other = 'other';

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(minutes: 5);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxImagesPerTreatment = 20;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);

  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 100;
  static const int maxNotesLength = 2000;
  static const int maxPhoneLength = 15;

  // Image
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1920;
  static const int imageQuality = 85;

  // Date Format
  static const String dateFormat = 'dd MMM yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd MMM yyyy, HH:mm';

  // Tooth Numbers (Universal Numbering System)
  static const List<String> upperRightTeeth = ['1', '2', '3', '4', '5', '6', '7', '8'];
  static const List<String> upperLeftTeeth = ['9', '10', '11', '12', '13', '14', '15', '16'];
  static const List<String> lowerLeftTeeth = ['17', '18', '19', '20', '21', '22', '23', '24'];
  static const List<String> lowerRightTeeth = ['25', '26', '27', '28', '29', '30', '31', '32'];

  // Common Dental Materials
  static const List<String> dentalMaterials = [
    'Composite Resin',
    'Amalgam',
    'Glass Ionomer',
    'Porcelain',
    'Gold Alloy',
    'Zirconia',
    'Ceramic',
    'Stainless Steel',
    'Resin-Modified Glass Ionomer',
    'Compomer',
  ];

  // Common Procedures
  static const Map<String, List<String>> treatmentProcedures = {
    orthodontics: [
      'Initial Consultation',
      'Braces Installation',
      'Adjustment',
      'Wire Change',
      'Elastics Placement',
      'Retainer Fitting',
      'Debonding',
      'Retention Check',
    ],
    fillings: [
      'Composite Filling',
      'Amalgam Filling',
      'Glass Ionomer Filling',
      'Temporary Filling',
      'Filling Replacement',
      'Cavity Preparation',
    ],
    scalingPolishing: [
      'Supragingival Scaling',
      'Subgingival Scaling',
      'Full Mouth Scaling',
      'Polishing',
      'Air Flow Polishing',
      'Deep Cleaning',
    ],
  };
}
