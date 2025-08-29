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

  // Colores específicos para inventario - Tema claro
  static const Color lightInventoryCard = Color(0xFFFFFFFF); // Blanco puro
  static const Color lightInventoryCardShadow = Color(0x1A000000); // Sombra suave
  static const Color lightInventoryAccent = Color(0xFF4CAF50); // Verde vibrante
  static const Color lightInventorySecondary = Color(0xFF2196F3); // Azul vibrante
  static const Color lightInventoryWarning = Color(0xFFFF9800); // Naranja
  static const Color lightInventoryDanger = Color(0xFFF44336); // Rojo
  static const Color lightInventorySuccess = Color(0xFF4CAF50); // Verde éxito
  static const Color lightInventoryText = Color(0xFF212121); // Texto principal
  static const Color lightInventoryTextSecondary = Color(0xFF757575); // Texto secundario
  static const Color lightInventoryDivider = Color(0xFFE0E0E0); // Divisor
  
  // Colores específicos para inventario - Tema oscuro
  static const Color darkInventoryCard = Color(0xFF2D2D2D); // Gris oscuro
  static const Color darkInventoryCardShadow = Color(0x33000000); // Sombra más fuerte
  static const Color darkInventoryAccent = Color(0xFF66BB6A); // Verde claro
  static const Color darkInventorySecondary = Color(0xFF42A5F5); // Azul claro
  static const Color darkInventoryWarning = Color(0xFFFFB74D); // Naranja claro
  static const Color darkInventoryDanger = Color(0xFFEF5350); // Rojo claro
  static const Color darkInventorySuccess = Color(0xFF66BB6A); // Verde éxito claro
  static const Color darkInventoryText = Color(0xFFE0E0E0); // Texto principal claro
  static const Color darkInventoryTextSecondary = Color(0xFFBDBDBD); // Texto secundario claro
  static const Color darkInventoryDivider = Color(0xFF424242); // Divisor oscuro

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
      
      surface: _lightSurface,
      onSurface: const Color(0xFF2E2E2E),
      surfaceContainerHighest: const Color(0xFFF0F0F0),
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
    
    cardTheme: CardThemeData(
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
      labelTextStyle: WidgetStateProperty.all(
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
      
      surface: _darkSurface,
      onSurface: const Color(0xFFE0E0E0),
      surfaceContainerHighest: const Color(0xFF3A3A3A),
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
    
    cardTheme: CardThemeData(
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
      labelTextStyle: WidgetStateProperty.all(
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

  static ThemeData getTheme(bool isDarkMode) {
    return isDarkMode ? darkTheme : lightTheme;
  }

  // Métodos para acceder a colores de inventario según el tema
  static Color getInventoryCardColor(bool isDarkMode) {
    return isDarkMode ? darkInventoryCard : lightInventoryCard;
  }

  static Color getInventoryCardShadow(bool isDarkMode) {
    return isDarkMode ? darkInventoryCardShadow : lightInventoryCardShadow;
  }

  static Color getInventoryAccentColor(bool isDarkMode) {
    return isDarkMode ? darkInventoryAccent : lightInventoryAccent;
  }

  static Color getInventorySecondaryColor(bool isDarkMode) {
    return isDarkMode ? darkInventorySecondary : lightInventorySecondary;
  }

  static Color getInventoryWarningColor(bool isDarkMode) {
    return isDarkMode ? darkInventoryWarning : lightInventoryWarning;
  }

  static Color getInventoryDangerColor(bool isDarkMode) {
    return isDarkMode ? darkInventoryDanger : lightInventoryDanger;
  }

  static Color getInventorySuccessColor(bool isDarkMode) {
    return isDarkMode ? darkInventorySuccess : lightInventorySuccess;
  }

  static Color getInventoryTextColor(bool isDarkMode) {
    return isDarkMode ? darkInventoryText : lightInventoryText;
  }

  static Color getInventoryTextSecondaryColor(bool isDarkMode) {
    return isDarkMode ? darkInventoryTextSecondary : lightInventoryTextSecondary;
  }

  static Color getInventoryDividerColor(bool isDarkMode) {
    return isDarkMode ? darkInventoryDivider : lightInventoryDivider;
  }
}