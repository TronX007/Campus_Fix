import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primaryBlue,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryBlue,
        secondary: AppColors.primaryOrange,
        surface: AppColors.surfaceLight,
        background: AppColors.backgroundLight,
        error: AppColors.statusRejected,
      ),
      textTheme: GoogleFonts.lexendTextTheme().copyWith(
        displayLarge: GoogleFonts.lexend(color: AppColors.textPrimaryLight, fontWeight: FontWeight.w900),
        displayMedium: GoogleFonts.lexend(color: AppColors.textPrimaryLight, fontWeight: FontWeight.w800),
        titleLarge: GoogleFonts.lexend(color: AppColors.textPrimaryLight, fontWeight: FontWeight.w800),
        titleMedium: GoogleFonts.lexend(color: AppColors.textPrimaryLight, fontWeight: FontWeight.bold),
        bodyLarge: GoogleFonts.lexend(color: AppColors.textPrimaryLight, fontWeight: FontWeight.w500),
        bodyMedium: GoogleFonts.lexend(color: AppColors.textSecondaryLight, fontWeight: FontWeight.w500),
        labelLarge: GoogleFonts.lexend(color: AppColors.textPrimaryLight, fontWeight: FontWeight.bold),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.lexend(
          color: AppColors.textPrimaryLight,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
        shape: const Border(
          bottom: BorderSide(color: Colors.black, width: 2.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        labelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        floatingLabelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black, width: 2.5),
          borderRadius: BorderRadius.circular(16),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black, width: 2.5),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2.5),
          borderRadius: BorderRadius.circular(16),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 2.5),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 2.5),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.black, width: 2.5),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.black, width: 2.5),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: AppColors.pastelOrange,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.black, width: 1.5),
          borderRadius: BorderRadius.circular(20),
        ),
        labelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
        secondaryLabelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
        brightness: Brightness.light,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.secondaryBlue,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.secondaryBlue,
        secondary: AppColors.primaryOrange,
        surface: AppColors.surfaceDark,
        background: AppColors.backgroundDark,
        error: AppColors.statusRejected,
      ),
      textTheme: GoogleFonts.lexendTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.lexend(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w900),
        displayMedium: GoogleFonts.lexend(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w800),
        titleLarge: GoogleFonts.lexend(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w800),
        titleMedium: GoogleFonts.lexend(color: AppColors.textPrimaryDark, fontWeight: FontWeight.bold),
        bodyLarge: GoogleFonts.lexend(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w500),
        bodyMedium: GoogleFonts.lexend(color: AppColors.textSecondaryDark, fontWeight: FontWeight.w500),
        labelLarge: GoogleFonts.lexend(color: AppColors.textPrimaryDark, fontWeight: FontWeight.bold),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.lexend(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
        shape: const Border(
          bottom: BorderSide(color: Colors.white, width: 2.0),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E1E24),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        floatingLabelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white, width: 2.0),
          borderRadius: BorderRadius.circular(16),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white, width: 2.0),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.secondaryBlue, width: 2.0),
          borderRadius: BorderRadius.circular(16),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.white, width: 2.0),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E24),
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.white, width: 2.0),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF1E1E24),
        selectedColor: AppColors.primaryBlue,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.white, width: 1.0),
          borderRadius: BorderRadius.circular(20),
        ),
        labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
        secondaryLabelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
        brightness: Brightness.dark,
      ),
    );
  }
}

