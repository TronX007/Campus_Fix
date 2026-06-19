import 'package:flutter/material.dart';

class AppColors {
  // Primary Blue & Orange Palette (Neobrutalist shades)
  static const Color primaryBlue = Color(0xFF4F46E5); // Indigo
  static const Color secondaryBlue = Color(0xFF3B82F6); // Bright Blue
  static const Color primaryOrange = Color(0xFFF97316); // Vibrant Orange
  static const Color secondaryOrange = Color(0xFFFB923C); // Warm Orange

  // Background & Shadow Colors
  static const Color backgroundLight = Color(0xFFF9F7F1); // Warm Beige
  static const Color backgroundDark = Color(0xFF121214); // Dark Charcoal
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1E1E24);
  static const Color borderBlack = Color(0xFF1E1E24); // Solid border color

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF1E1E24); // Solid black
  static const Color textSecondaryLight = Color(0xFF555558); // Muted black
  static const Color textPrimaryDark = Color(0xFFF9F7F1);
  static const Color textSecondaryDark = Color(0xFF9E9EA5);

  // Status Colors (Solid High-Contrast)
  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusInProgress = Color(0xFF3B82F6);
  static const Color statusResolved = Color(0xFF10B981);
  static const Color statusRejected = Color(0xFFEF4444);

  // Priority Colors
  static const Color priorityLow = Color(0xFF10B981);
  static const Color priorityMedium = Color(0xFFF59E0B);
  static const Color priorityHigh = Color(0xFFF97316);
  static const Color priorityCritical = Color(0xFFEF4444);

  // Neobrutalist Pastel Accents
  static const Color pastelMint = Color(0xFFA7F3D0);
  static const Color pastelPurple = Color(0xFFDDD6FE);
  static const Color pastelOrange = Color(0xFFFED7AA);
  static const Color pastelYellow = Color(0xFFFEF08A);
  static const Color pastelPink = Color(0xFFFBCFE8);
  static const Color pastelBlue = Color(0xFFBFDBFE);
  static const Color pastelTeal = Color(0xFF99F6E4);
  static const Color pastelRose = Color(0xFFFECDD3);

  // Category Color Map helper
  static Color getCategoryColor(String category) {
    switch (category) {
      case 'Campus Life':
        return pastelOrange;
      case 'Academics & Study Spaces':
      case 'Academics':
        return pastelPurple;
      case 'Sustainability & Green':
        return pastelMint;
      case 'Technology & Wi-Fi':
      case 'Wi-Fi/Internet':
        return pastelBlue;
      case 'Hostel & Dining':
      case 'Hostel/Mess':
        return pastelYellow;
      case 'Sports & Recreation':
        return pastelTeal;
      case 'Events & Culture':
        return pastelPink;
      default:
        return pastelRose;
    }
  }
}

