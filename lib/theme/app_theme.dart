import 'package:flutter/material.dart';

class AppTheme {
  // Colores pastel para tema claro
  static const Color _lightPrimary = Color(0xFFB8E6B8); // Verde pastel
  static const Color _lightSecondary = Color(0xFFFFD1DC); // Rosa pastel
  static const Color _lightTertiary = Color(0xFFE6E6FA); // Lavanda pastel
  static const Color _lightBackground = Color(0xFFFFFFF8); // Blanco crema
  static const Color _lightSurface = Color(0xFFF8F8FF); // Blanco fantasma
  static const Color _lightError = Color(0xFFFFB3BA); // Rojo pastel
  
  // Colores pastel para tema oscuro
  static const Color _darkPrimary = Color(0xFF4A6741); // Verde oscuro pastel
  static const Color _darkSecondary = Color(0xFF6B4C57); // Rosa oscuro pastel
  static const Color _darkTertiary = Color(0xFF5D5A6B); // Lavanda oscuro pastel
  static const Color _darkBackground = Color(0xFF1A1A1A); // Negro suave
  static const Color _darkSurface = Color(0xFF2A2A2A); // Gris oscuro
  static const Color _darkError = Color(0xFF8B4A47); // Rojo oscuro pastel

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: _lightPrimary,
      onPrimary: const Color(0xFF1B5E20),
      primaryContainer: _lightPrimary.withOpacity(0.3),
      onPrimaryContainer: const Color(0xFF1B5E20),
      
      secondary: _lightSecondary,
      onSecondary: const Color(0xFF8E24AA),
      secondaryContainer: _lightSecondary.withOpacity(0.3),
      onSecondaryContainer: const Color(0xFF8E24AA),
      
      tertiary: _lightTertiary,
      onTertiary: const Color(0xFF512DA8),
      tertiaryContainer: _lightTertiary.withOpacity(0.3),
      onTertiaryContainer: const Color(0xFF512DA8),
      
      error: _lightError,
      onError: const Color(0xFFD32F2F),
      errorContainer: _lightError.withOpacity(0.3),
      onErrorContainer: const Color(0xFFD32F2F),
      
      background: _lightBackground,
      onBackground: const Color(0xFF2E2E2E),
      
      surface: _lightSurface,
      onSurface: const Color(0xFF2E2E2E),
      surfaceVariant: const Color(0xFFF0F0F0),
      onSurfaceVariant: const Color(0xFF5E5E5E),
      
      outline: const Color(0xFFBDBDBD),
      outlineVariant: const Color(0xFFE0E0E0),
      
      shadow: Colors.black.withOpacity(0.1),
      scrim: Colors.black.withOpacity(0.5),
      
      inverseSurface: const Color(0xFF2E2E2E),
      onInverseSurface: _lightBackground,
      inversePrimary: _darkPrimary,
    ),
    
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFF2E2E2E),
      titleTextStyle: TextStyle(
        color: Color(0xFF2E2E2E),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: _lightSurface,
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: _lightPrimary,
      foregroundColor: const Color(0xFF1B5E20),
    ),
    
    navigationBarTheme: NavigationBarThemeData(
      elevation: 8,
      backgroundColor: _lightSurface.withOpacity(0.9),
      indicatorColor: _lightPrimary.withOpacity(0.3),
      labelTextStyle: MaterialStateProperty.all(
        const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _lightSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: const Color(0xFFBDBDBD).withOpacity(0.3),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: _lightPrimary,
          width: 2,
        ),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: _darkPrimary,
      onPrimary: const Color(0xFFE8F5E8),
      primaryContainer: _darkPrimary.withOpacity(0.3),
      onPrimaryContainer: const Color(0xFFE8F5E8),
      
      secondary: _darkSecondary,
      onSecondary: const Color(0xFFFCE4EC),
      secondaryContainer: _darkSecondary.withOpacity(0.3),
      onSecondaryContainer: const Color(0xFFFCE4EC),
      
      tertiary: _darkTertiary,
      onTertiary: const Color(0xFFF3E5F5),
      tertiaryContainer: _darkTertiary.withOpacity(0.3),
      onTertiaryContainer: const Color(0xFFF3E5F5),
      
      error: _darkError,
      onError: const Color(0xFFFFEBEE),
      errorContainer: _darkError.withOpacity(0.3),
      onErrorContainer: const Color(0xFFFFEBEE),
      
      background: _darkBackground,
      onBackground: const Color(0xFFE0E0E0),
      
      surface: _darkSurface,
      onSurface: const Color(0xFFE0E0E0),
      surfaceVariant: const Color(0xFF3A3A3A),
      onSurfaceVariant: const Color(0xFFB0B0B0),
      
      outline: const Color(0xFF5E5E5E),
      outlineVariant: const Color(0xFF4A4A4A),
      
      shadow: Colors.black.withOpacity(0.3),
      scrim: Colors.black.withOpacity(0.7),
      
      inverseSurface: const Color(0xFFE0E0E0),
      onInverseSurface: _darkBackground,
      inversePrimary: _lightPrimary,
    ),
    
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFFE0E0E0),
      titleTextStyle: TextStyle(
        color: Color(0xFFE0E0E0),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    
    cardTheme: CardTheme(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: _darkSurface,
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: _darkPrimary,
      foregroundColor: const Color(0xFFE8F5E8),
    ),
    
    navigationBarTheme: NavigationBarThemeData(
      elevation: 8,
      backgroundColor: _darkSurface.withOpacity(0.9),
      indicatorColor: _darkPrimary.withOpacity(0.3),
      labelTextStyle: MaterialStateProperty.all(
        const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: const Color(0xFF5E5E5E).withOpacity(0.3),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: _darkPrimary,
          width: 2,
        ),
      ),
    ),
  );
}