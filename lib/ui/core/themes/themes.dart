import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color primary = Color(0xFF0B73DC);
  static const Color black = Color.fromARGB(196, 0, 0, 0);
  static const Color white = Color.fromARGB(255, 249, 252, 254);
  static const Color lightblack = Color.fromARGB(156, 0, 0, 0);
  static const Color red = Color.fromARGB(255, 238, 68, 67);
  static const Color black50 = Color.from(
    alpha: 0.5,
    red: 0,
    green: 0,
    blue: 0,
  );
}

abstract final class AppThemes {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: Color(0xFFF5F7FB),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: Colors.grey,
      brightness: Brightness.light,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0.3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
    ),
    cardColor: Colors.white,
    // cardColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.black),
      titleTextStyle: TextStyle(
        color: AppColors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.grey, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
      ),
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: Colors.grey,
      brightness: Brightness.dark,
      surface: const Color(0xFF121212),
      onSurface: Colors.white.withAlpha(225),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E),
      elevation: 0.3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
    ),
    cardColor: const Color(0xFF1E1E1E),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1E1E1E),
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.grey, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
      ),
    ),
  );
}

abstract final class AppStyles {
  static TextStyle titleTextSmall(BuildContext context) => TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.bold,
    color: Theme.of(context).textTheme.titleMedium?.color,
  );

  static TextStyle titleTextMedium(BuildContext context) => TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Theme.of(context).textTheme.titleLarge?.color,
  );

  static TextStyle titleTextLarge(BuildContext context) => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Theme.of(context).textTheme.titleLarge?.color,
  );

  static TextStyle subtitleText(BuildContext context) => TextStyle(
    fontSize: 14,
    color: Theme.of(
      context,
    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
  );

  static TextStyle labelText(BuildContext context) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Theme.of(context).colorScheme.onSurfaceVariant,
  );

  static const double cardElevation = 0.2;
}
