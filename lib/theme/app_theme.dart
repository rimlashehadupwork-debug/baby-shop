import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AppColors {
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color secondaryPink = Color(0xFFF48FA8);
  static const Color accentBlue = Color(0xFF7CC8E8);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color primaryText = Color(0xFF243447);
  static const Color secondaryText = Color(0xFF64748B);
  static const Color success = Color(0xFF43A047);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFE05D6F);
  static const Color border = Color(0xFFE2E8F0);
  static const Color inputBackground = Color(0xFFF8FAFC);
  static const Color softBlue = Color(0xFFEAF3FC);
  static const Color softPink = Color(0xFFFDEEF2);
}

class AppShadows {
  static List<BoxShadow> get card => [
        BoxShadow(
          color: const Color(0xFF243447).withValues(alpha: 0.05),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];
  static List<BoxShadow> get soft => [
        BoxShadow(
          color: const Color(0xFF243447).withValues(alpha: 0.03),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryBlue,
        secondary: AppColors.secondaryPink,
        tertiary: AppColors.accentBlue,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.primaryText,
        onError: Colors.white,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.primaryText),
        titleTextStyle: TextStyle(
          color: AppColors.primaryText,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.primaryText, letterSpacing: -0.4),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primaryText, letterSpacing: -0.3),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primaryText),
        bodyMedium: TextStyle(fontSize: 14, color: AppColors.primaryText, height: 1.4),
        bodySmall: TextStyle(fontSize: 12, color: AppColors.secondaryText, height: 1.4),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1, space: 1),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primaryText,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primaryBlue,
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.primaryText),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.softBlue,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
              fontSize: 11,
              fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
              color: states.contains(WidgetState.selected) ? AppColors.primaryBlue : AppColors.secondaryText,
            )),
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
              size: 24,
              color: states.contains(WidgetState.selected) ? AppColors.primaryBlue : AppColors.secondaryText,
            )),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(
          color: AppColors.secondaryText,
          fontSize: 14,
        ),
        labelStyle: const TextStyle(
          color: AppColors.secondaryText,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.8),
        ),
      ),
    );
  }
}
