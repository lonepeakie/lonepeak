import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color blue = Color(0xFF0B73DC);
  static const Color black = Color.fromARGB(196, 0, 0, 0);
  static const Color white = Color.fromARGB(255, 249, 252, 254);
}

abstract final class AppThemes {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.blue,
      primary: AppColors.blue,
      secondary: Colors.grey,
      brightness: Brightness.light,
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.blue,
      primary: AppColors.blue,
      secondary: Colors.grey,
      brightness: Brightness.dark,
    ),
  );
}

abstract final class AppStyles {
  static const TextStyle titleText = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
  );
  static const TextStyle subtitleText = TextStyle(
    fontSize: 14,
    color: Color.fromARGB(156, 0, 0, 0),
  );
}
