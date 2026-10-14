import 'package:flutter/material.dart';

/// Paleta y tema de "Voley Score" — estilo colorido con vibra de playa.
class AppColors {
  // Atardecer de playa
  static const Color sunsetOrange = Color(0xFFFF7A00);
  static const Color sunsetDeep = Color(0xFFF25C05);
  static const Color sunYellow = Color(0xFFFFC93C);
  static const Color turquoise = Color(0xFF00B8A9);
  static const Color turquoiseDeep = Color(0xFF00837A);
  static const Color oceanBlue = Color(0xFF0E7C9B);

  // Equipos
  static const Color teamA = Color(0xFFE53935); // rojo
  static const Color teamB = Color(0xFF1E6FEB); // azul

  // Neutros
  static const Color sand = Color(0xFFFFF6EA);
  static const Color darkBg = Color(0xFF12161C);
  static const Color darkSurface = Color(0xFF1B2129);
  static const Color ink = Color(0xFF16222E);
}

class AppGradients {
  static const LinearGradient sunset = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.sunYellow, AppColors.sunsetOrange, AppColors.sunsetDeep],
  );

  static const LinearGradient beach = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.turquoise, AppColors.oceanBlue],
  );

  static const LinearGradient teamA = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEF5350), Color(0xFFC62828)],
  );

  static const LinearGradient teamB = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF42A5F5), Color(0xFF0D47A1)],
  );
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: AppColors.sunsetOrange,
            brightness: Brightness.light,
          ).copyWith(
            primary: AppColors.sunsetDeep,
            secondary: AppColors.turquoise,
            surface: AppColors.sand,
          ),
      scaffoldBackgroundColor: AppColors.sand,
    );
    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.ink,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 3,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: AppColors.sunsetOrange,
            brightness: Brightness.dark,
          ).copyWith(
            primary: AppColors.sunsetOrange,
            secondary: AppColors.turquoise,
            surface: AppColors.darkSurface,
          ),
      scaffoldBackgroundColor: AppColors.darkBg,
    );
    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        color: AppColors.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
    );
  }
}
