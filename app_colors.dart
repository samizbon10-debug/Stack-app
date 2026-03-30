import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Dental/Clinical Theme
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryLight = Color(0xFF64B5F6);
  static const Color primaryDark = Color(0xFF1976D2);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF00BCD4);
  static const Color secondaryLight = Color(0xFF4DD0E1);
  static const Color secondaryDark = Color(0xFF0097A7);
  
  // Background Colors
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF0F4F8);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1A237E);
  static const Color textSecondary = Color(0xFF5C6BC0);
  static const Color textHint = Color(0xFF9FA8DA);
  static const Color textOnPrimary = Colors.white;
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFC8E6C9);
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFE0B2);
  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFFFCDD2);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFBBDEFB);
  
  // Treatment Category Colors
  static const Color orthodontics = Color(0xFF9C27B0);
  static const Color orthodonticsLight = Color(0xFFE1BEE7);
  static const Color fillings = Color(0xFFFF5722);
  static const Color fillingsLight = Color(0xFFFFCCBC);
  static const Color scalingPolishing = Color(0xFF009688);
  static const Color scalingPolishingLight = Color(0xFFB2DFDB);
  
  // Other UI Colors
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFBDBDBD);
  static const Color shadow = Color(0x1F000000);
  static const Color overlay = Color(0x52000000);
  static const Color cardBackground = Colors.white;
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient headerGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Helper method to get treatment color
  static Color getTreatmentColor(String category) {
    switch (category.toLowerCase()) {
      case 'orthodontics':
        return orthodontics;
      case 'fillings':
        return fillings;
      case 'scaling_polishing':
      case 'scalingpolishing':
        return scalingPolishing;
      default:
        return primary;
    }
  }
  
  static Color getTreatmentLightColor(String category) {
    switch (category.toLowerCase()) {
      case 'orthodontics':
        return orthodonticsLight;
      case 'fillings':
        return fillingsLight;
      case 'scaling_polishing':
      case 'scalingpolishing':
        return scalingPolishingLight;
      default:
        return primaryLight;
    }
  }
}
