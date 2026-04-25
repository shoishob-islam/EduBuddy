import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color Palette
  static const Color bgPrimary = Color(0xFF080810);
  static const Color bgSecondary = Color(0xFF0D0D1A);
  static const Color bgCard = Color(0xFF12121F);
  static const Color bgCardHover = Color(0xFF1A1A2E);

  static const Color neonPurple = Color(0xFF9B30FF);
  static const Color neonPurpleLight = Color(0xFFBF6FFF);
  static const Color neonPurpleDark = Color(0xFF6A0FCC);
  static const Color neonPink = Color(0xFFFF30AA);
  static const Color neonBlue = Color(0xFF30AAFF);

  static const Color textPrimary = Color(0xFFF0F0FF);
  static const Color textSecondary = Color(0xFF8888AA);
  static const Color textMuted = Color(0xFF444466);

  static const Color borderColor = Color(0xFF1E1E3A);
  static const Color dividerColor = Color(0xFF1A1A30);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [neonPurple, neonPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF13132A), Color(0xFF0D0D1A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGlow = LinearGradient(
    colors: [Color(0xff9b30ff22), Color(0xff9b30ff00)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Shadows
  static List<BoxShadow> neonShadow = [
    BoxShadow(
      color: neonPurple.withOpacity(0.4),
      blurRadius: 20,
      spreadRadius: 2,
    ),
  ];

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.5),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: neonPurple.withOpacity(0.05),
      blurRadius: 20,
      spreadRadius: 1,
    ),
  ];

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgPrimary,
      colorScheme: const ColorScheme.dark(
        primary: neonPurple,
        secondary: neonPink,
        surface: bgSecondary,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.spaceGrotesk(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          letterSpacing: -1,
        ),
        displayMedium: GoogleFonts.spaceGrotesk(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        headlineLarge: GoogleFonts.spaceGrotesk(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        headlineMedium: GoogleFonts.spaceGrotesk(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          height: 1.5,
        ),
        labelLarge: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.5,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: neonPurple, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red),
        ),
        hintStyle: GoogleFonts.inter(color: textMuted, fontSize: 14),
        labelStyle: GoogleFonts.inter(color: textSecondary),
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: neonPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.spaceGrotesk(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          elevation: 0,
        ),
      ),
      cardTheme: CardThemeData(
        color: bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderColor),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bgPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: bgSecondary,
        selectedItemColor: neonPurple,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: bgCard,
        contentTextStyle: GoogleFonts.inter(color: textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
