import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

/// Configuration des thèmes adaptatifs pour l'application ReWatch.
///
/// Intègre la nouvelle identité "Cinema Premium".
class AppThemes {
  AppThemes._();

  // Font Family
  static const String kFontFamily = 'Sora';

  /// Thème Dark (Principal pour une app de cinéma)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: kFontFamily,
      scaffoldBackgroundColor: AppColors.kBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.kPrimary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.kPrimaryContainer,
        onPrimaryContainer: AppColors.kPrimaryLight,
        secondary: AppColors.kSuccess,
        onSecondary: Colors.black,
        surface: AppColors.kSurface,
        onSurface: AppColors.kTextPrimary,
        surfaceContainerHighest: AppColors.kSurfaceElevated,
        onSurfaceVariant: AppColors.kTextSecondary,
        error: AppColors.kError,
        onError: Colors.white,
        outline: AppColors.kBorder,
        outlineVariant: AppColors.kDivider,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.kBackground,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.kTextPrimary),
        titleTextStyle: TextStyle(
          fontFamily: kFontFamily,
          color: AppColors.kTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.kSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: AppColors.kBorder,
            width: 1,
          ), // Subtle border in dark mode
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.kPrimary,
          foregroundColor: Colors.white,
          elevation: 0, // Flat design
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: kFontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.kSurfaceElevated,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.kPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.kError, width: 1.5),
        ),
        hintStyle: const TextStyle(color: AppColors.kTextTertiary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.kSurface,
        selectedItemColor: AppColors.kPrimary,
        unselectedItemColor: AppColors.kTextTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.kDivider,
        thickness: 1,
      ),
    );
  }

  /// Thème Light (Alternative lumineuse)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: kFontFamily,
      scaffoldBackgroundColor: AppColors.kLightBackground,
      colorScheme: const ColorScheme.light(
        primary:
            AppColors.kPrimaryDark, // Plus foncé pour le contraste sur blanc
        onPrimary: Colors.white,
        secondary: AppColors.kSuccess,
        surface: AppColors.kLightSurface,
        onSurface: AppColors.kLightTextPrimary,
        surfaceContainerHighest: AppColors.kSurfaceOverlay,
        onSurfaceVariant: AppColors.kLightTextSecondary,
        error: AppColors.kError,
        outline: AppColors.kLightBorder,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.kLightBackground,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.kLightTextPrimary),
        titleTextStyle: TextStyle(
          fontFamily: kFontFamily,
          color: AppColors.kLightTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.kLightSurface,
        elevation: 2, // Légère ombre en light mode pour le relief
        shadowColor: Colors.black.withOpacity(0.05),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide.none,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.kPrimaryDark,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: kFontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.kLightSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.kLightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.kLightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.kPrimaryDark,
            width: 1.5,
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.kLightSurface,
        selectedItemColor: AppColors.kPrimaryDark,
        unselectedItemColor: AppColors.kTextTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  // Backward compatibility alias
  static ThemeData get materialTheme => darkTheme;

  /// Thème Cupertino pour iOS.
  static CupertinoThemeData get cupertinoTheme {
    return CupertinoThemeData(
      primaryColor: AppColors.kPrimary,
      scaffoldBackgroundColor: AppColors.kBackground,
      barBackgroundColor: AppColors.kSurface.withOpacity(0.9),
      brightness: Brightness.dark, // Default to dark aesthetic
      textTheme: CupertinoTextThemeData(
        primaryColor: AppColors.kTextPrimary,
        textStyle: TextStyle(
          fontFamily: kFontFamily,
          color: AppColors.kTextPrimary,
          fontSize: 17.sp,
        ),
        navTitleTextStyle: TextStyle(
          fontFamily: kFontFamily,
          color: AppColors.kTextPrimary,
          fontSize: 17.sp,
          fontWeight: FontWeight.w600,
        ),
        navLargeTitleTextStyle: TextStyle(
          fontFamily: kFontFamily,
          color: AppColors.kTextPrimary,
          fontSize: 34.sp,
          fontWeight: FontWeight.bold,
        ),
        pickerTextStyle: TextStyle(
          fontFamily: kFontFamily,
          color: AppColors.kTextPrimary,
          fontSize: 21.sp,
        ),
        dateTimePickerTextStyle: TextStyle(
          fontFamily: kFontFamily,
          color: AppColors.kTextPrimary,
          fontSize: 21.sp,
        ),
        tabLabelTextStyle: TextStyle(
          fontFamily: kFontFamily,
          color: AppColors.kTextSecondary,
          fontSize: 10.sp,
        ),
        navActionTextStyle: TextStyle(
          fontFamily: kFontFamily,
          color: AppColors.kPrimary,
          fontSize: 17.sp,
        ),
      ),
    );
  }
}
