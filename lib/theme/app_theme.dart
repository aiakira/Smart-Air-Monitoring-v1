import 'package:flutter/material.dart';

class AppTheme {
  // Spacing
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;

  // Border Radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;

  // Elevation
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;

  // Colors
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);

  // Text Styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );

  static const TextStyle sensorLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textSecondaryColor,
  );

  static const TextStyle sensorValue = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );

  static const TextStyle sensorUnit = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textSecondaryColor,
  );

  // Theme Colors
  static const Color primaryBlue = Color(0xFF1976D2);
  static const Color primaryGreen = Color(0xFF388E3C);
  static const Color primaryPurple = Color(0xFF7B1FA2);
  static const Color primaryOrange = Color(0xFFE65100);

  // Health Status Colors
  static const Color healthExcellent = Color(0xFF4CAF50);
  static const Color healthGood = Color(0xFF8BC34A);
  static const Color healthFair = Color(0xFFFFEB3B);
  static const Color healthPoor = Color(0xFFFF9800);
  static const Color healthDangerous = Color(0xFFF44336);

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: elevationLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLarge,
            vertical: spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusSmall),
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.dark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey.shade900,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: elevationLow,
        color: Colors.grey.shade800,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLarge,
            vertical: spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusSmall),
          ),
        ),
      ),
    );
  }

  // Theme variants
  static ThemeData getTheme(String themeName, bool isDark) {
    Color seedColor;
    switch (themeName) {
      case 'green':
        seedColor = primaryGreen;
        break;
      case 'purple':
        seedColor = primaryPurple;
        break;
      case 'orange':
        seedColor = primaryOrange;
        break;
      default:
        seedColor = primaryBlue;
    }

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: isDark ? Brightness.dark : Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? Colors.grey.shade900 : seedColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: elevationLow,
        color: isDark ? Colors.grey.shade800 : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLarge,
            vertical: spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusSmall),
          ),
        ),
      ),
    );
  }
}
