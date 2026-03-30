import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Utility helper functions for the app
class AppHelpers {
  // Date Formatting
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  static String formatShortDate(DateTime date) {
    return DateFormat('dd/MM/yy').format(date);
  }

  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes} min ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? '1 year ago' : '$years years ago';
    }
  }

  static String formatDateForFolder(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Phone Formatting
  static String formatPhoneNumber(String phone) {
    // Remove all non-digit characters
    String cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Format based on length
    if (cleaned.length == 10) {
      return '${cleaned.substring(0, 3)}-${cleaned.substring(3, 6)}-${cleaned.substring(6)}';
    } else if (cleaned.length == 11) {
      return '${cleaned.substring(0, 4)}-${cleaned.substring(4, 7)}-${cleaned.substring(7)}';
    }
    return phone;
  }

  // Name Formatting
  static String getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ')
        .map((word) => word.isEmpty
            ? word
            : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  // Age Calculator
  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  static String ageToString(int age) {
    return '$age years';
  }

  // Color Helpers
  static Color getTreatmentColor(String category) {
    switch (category) {
      case 'orthodontics':
        return const Color(0xFF7C4DFF);
      case 'fillings':
        return const Color(0xFF26A69A);
      case 'scaling_polishing':
        return const Color(0xFFFF7043);
      default:
        return const Color(0xFF2196F3);
    }
  }

  static Color getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return const Color(0xFF4CAF50);
      case 'in_progress':
        return const Color(0xFFFF9800);
      case 'scheduled':
        return const Color(0xFF2196F3);
      case 'confirmed':
        return const Color(0xFF00BCD4);
      case 'cancelled':
        return const Color(0xFFE53935);
      case 'planned':
        return const Color(0xFF9C27B0);
      default:
        return Colors.grey;
    }
  }

  // String Validation
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    return cleaned.length >= 10 && cleaned.length <= 15;
  }

  // File Size Formatter
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  // Duration Formatter
  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    } else {
      int hours = minutes ~/ 60;
      int mins = minutes % 60;
      if (mins == 0) {
        return '$hours hr';
      }
      return '$hours hr $mins min';
    }
  }

  // Tooth Number Helper
  static String getToothName(String toothNumber) {
    final tooth = int.tryParse(toothNumber);
    if (tooth == null) return 'Unknown';

    if (tooth >= 1 && tooth <= 8) {
      return 'Upper Right $toothNumber';
    } else if (tooth >= 9 && tooth <= 16) {
      return 'Upper Left $toothNumber';
    } else if (tooth >= 17 && tooth <= 24) {
      return 'Lower Left $toothNumber';
    } else if (tooth >= 25 && tooth <= 32) {
      return 'Lower Right $toothNumber';
    }
    return 'Unknown';
  }

  static String getToothType(String toothNumber) {
    final tooth = int.tryParse(toothNumber);
    if (tooth == null) return 'Unknown';

    // Adjust for quadrant
    int position = ((tooth - 1) % 8) + 1;

    if (position == 1) return 'Central Incisor';
    if (position == 2) return 'Lateral Incisor';
    if (position == 3) return 'Canine';
    if (position == 4 || position == 5) return 'Premolar';
    if (position >= 6 && position <= 8) return 'Molar';
    return 'Unknown';
  }

  // Search Helper
  static bool matchesSearch(String query, List<String> fields) {
    final lowerQuery = query.toLowerCase();
    return fields.any((field) => field.toLowerCase().contains(lowerQuery));
  }
}
