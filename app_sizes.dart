class AppSizes {
  // Padding & Margin
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 48.0;
  
  // Border Radius
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 12.0;
  static const double radiusXL = 16.0;
  static const double radiusXXL = 24.0;
  static const double radiusRound = 100.0;
  
  // Card
  static const double cardElevation = 2.0;
  static const double cardBorderRadius = radiusL;
  
  // Button
  static const double buttonHeight = 48.0;
  static const double buttonHeightS = 40.0;
  static const double buttonHeightL = 56.0;
  static const double buttonRadius = radiusM;
  
  // Input
  static const double inputHeight = 56.0;
  static const double inputBorderRadius = radiusM;
  
  // Icon
  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;
  
  // Avatar
  static const double avatarS = 32.0;
  static const double avatarM = 48.0;
  static const double avatarL = 64.0;
  static const double avatarXL = 96.0;
  static const double avatarXXL = 128.0;
  
  // Font
  static const double fontXS = 10.0;
  static const double fontS = 12.0;
  static const double fontM = 14.0;
  static const double fontL = 16.0;
  static const double fontXL = 18.0;
  static const double fontXXL = 24.0;
  static const double fontDisplay = 32.0;
  
  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  
  // Animation Duration
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationMedium = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);
  static const Duration durationXSlow = Duration(milliseconds: 800);
}

class AppDefaults {
  // Default image quality
  static const int imageQuality = 85;
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1920;
  
  // Thumbnail
  static const int thumbnailSize = 200;
  
  // Pagination
  static const int patientsPerPage = 20;
  static const int treatmentsPerPage = 10;
  
  // Backup
  static const int backupRetryAttempts = 3;
  static const Duration backupTimeout = Duration(minutes: 10);
  
  // Cache
  static const Duration cacheExpiry = Duration(days: 7);
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB
  
  // Appointment
  static const int defaultAppointmentDuration = 30; // minutes
  static const int minAppointmentDuration = 15;
  static const int maxAppointmentDuration = 240;
}
