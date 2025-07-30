import 'package:flutter/material.dart';

abstract final class AppColors {
  // Primary colors from Tailwind CSS theme
  static const Color primary = Color(
    0xFF3B82F6,
  ); // oklch(0.6231 0.1880 259.8145)
  static const Color primaryForeground = Color(0xFFFFFFFF); // oklch(1.0000 0 0)

  // Background colors
  static const Color background = Color(0xFFFFFFFF); // oklch(1.0000 0 0)
  static const Color foreground = Color(0xFF525252); // oklch(0.3211 0 0)

  // Card colors
  static const Color card = Color(0xFFFFFFFF); // oklch(1.0000 0 0)
  static const Color cardForeground = Color(0xFF525252); // oklch(0.3211 0 0)

  // Secondary colors
  static const Color secondary = Color(
    0xFFF4F4F5,
  ); // oklch(0.9670 0.0029 264.5419)
  static const Color secondaryForeground = Color(
    0xFF71717A,
  ); // oklch(0.4461 0.0263 256.8018)

  // Muted colors
  static const Color muted = Color(0xFFFAFAFA); // oklch(0.9846 0.0017 247.8389)
  static const Color mutedForeground = Color(
    0xFF8B8B8B,
  ); // oklch(0.5510 0.0234 264.3637)

  // Accent colors
  static const Color accent = Color(
    0xFFF1F2F6,
  ); // oklch(0.9514 0.0250 236.8242)
  static const Color accentForeground = Color(
    0xFF6366F1,
  ); // oklch(0.3791 0.1378 265.5222)

  // Border and input
  static const Color border = Color(
    0xFFE4E4E7,
  ); // oklch(0.9276 0.0058 264.5313)
  static const Color input = Color(0xFFE4E4E7); // oklch(0.9276 0.0058 264.5313)

  // Destructive
  static const Color destructive = Color(
    0xFFEF4444,
  ); // oklch(0.6368 0.2078 25.3313)
  static const Color destructiveForeground = Color(
    0xFFFFFFFF,
  ); // oklch(1.0000 0 0)

  // Ring
  static const Color ring = Color(0xFF3B82F6); // oklch(0.6231 0.1880 259.8145)

  // Chart colors
  static const Color chart1 = Color(
    0xFF3B82F6,
  ); // oklch(0.6231 0.1880 259.8145)
  static const Color chart2 = Color(
    0xFF8B5CF6,
  ); // oklch(0.5461 0.2152 262.8809)
  static const Color chart3 = Color(
    0xFF7C3AED,
  ); // oklch(0.4882 0.2172 264.3763)
  static const Color chart4 = Color(
    0xFF6D28D9,
  ); // oklch(0.4244 0.1809 265.6377)
  static const Color chart5 = Color(
    0xFF6366F1,
  ); // oklch(0.3791 0.1378 265.5222)

  // Dark theme colors
  static const Color backgroundDark = Color(0xFF0A0A0A); // oklch(0.1684 0 0)
  static const Color foregroundDark = Color(0xFFEBEBEB); // oklch(0.9219 0 0)
  static const Color cardDark = Color(0xFF141414); // oklch(0.1913 0 0)
  static const Color cardForegroundDark = Color(
    0xFFEBEBEB,
  ); // oklch(0.9219 0 0)
  static const Color secondaryDark = Color(0xFF404040); // oklch(0.2686 0 0)
  static const Color secondaryForegroundDark = Color(
    0xFFEBEBEB,
  ); // oklch(0.9219 0 0)
  static const Color mutedDark = Color(0xFF141414); // oklch(0.1913 0 0)
  static const Color mutedForegroundDark = Color(
    0xFFB3B3B3,
  ); // oklch(0.7155 0 0)
  static const Color accentDark = Color(
    0xFF6366F1,
  ); // oklch(0.3791 0.1378 265.5222)
  static const Color accentForegroundDark = Color(
    0xFFE1E5FF,
  ); // oklch(0.8823 0.0571 254.1284)
  static const Color borderDark = Color(0xFF5E5E5E); // oklch(0.3715 0 0)
  static const Color inputDark = Color(0xFF5E5E5E); // oklch(0.3715 0 0)

  // Sidebar colors
  static const Color sidebar = Color(
    0xFFFAFAFA,
  ); // oklch(0.9846 0.0017 247.8389)
  static const Color sidebarForeground = Color(0xFF525252); // oklch(0.3211 0 0)
  static const Color sidebarPrimary = Color(
    0xFF3B82F6,
  ); // oklch(0.6231 0.1880 259.8145)
  static const Color sidebarPrimaryForeground = Color(
    0xFFFFFFFF,
  ); // oklch(1.0000 0 0)
  static const Color sidebarAccent = Color(
    0xFFF1F2F6,
  ); // oklch(0.9514 0.0250 236.8242)
  static const Color sidebarAccentForeground = Color(
    0xFF6366F1,
  ); // oklch(0.3791 0.1378 265.5222)
  static const Color sidebarBorder = Color(
    0xFFE4E4E7,
  ); // oklch(0.9276 0.0058 264.5313)
  static const Color sidebarRing = Color(
    0xFF3B82F6,
  ); // oklch(0.6231 0.1880 259.8145)

  // Sidebar dark colors
  static const Color sidebarDark = Color(0xFF333333); // oklch(0.2046 0 0)
  static const Color sidebarForegroundDark = Color(
    0xFFEBEBEB,
  ); // oklch(0.9219 0 0)
  static const Color sidebarAccentDark = Color(
    0xFF6366F1,
  ); // oklch(0.3791 0.1378 265.5222)
  static const Color sidebarAccentForegroundDark = Color(
    0xFFE1E5FF,
  ); // oklch(0.8823 0.0571 254.1284)
  static const Color sidebarBorderDark = Color(0xFF5E5E5E); // oklch(0.3715 0 0)

  // Legacy colors (keeping for backward compatibility)
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
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.primaryForeground,
      secondary: AppColors.secondary,
      onSecondary: AppColors.secondaryForeground,
      surface: AppColors.card,
      onSurface: AppColors.cardForeground,
      surfaceContainerHighest: AppColors.accent,
      onSurfaceVariant: AppColors.mutedForeground,
      outline: AppColors.border,
      outlineVariant: AppColors.input,
      error: AppColors.destructive,
      onError: AppColors.destructiveForeground,
      surfaceContainer: AppColors.muted,
    ),
    cardTheme: CardTheme(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
      shadowColor: Colors.black.withValues(alpha: 0.05),
      surfaceTintColor: Colors.transparent,
    ),
    cardColor: AppColors.card,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.card,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.foreground),
      titleTextStyle: TextStyle(
        color: AppColors.foreground,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6.0),
        borderSide: BorderSide(color: AppColors.border, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6.0),
        borderSide: BorderSide(color: AppColors.ring, width: 2.0),
      ),
      filled: true,
      fillColor: AppColors.background,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.primaryForeground,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: AppColors.border, width: 1.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
      ),
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    primaryColor: AppColors.primary,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: AppColors.primaryForeground,
      secondary: AppColors.secondaryDark,
      onSecondary: AppColors.secondaryForegroundDark,
      surface: AppColors.cardDark,
      onSurface: AppColors.cardForegroundDark,
      surfaceContainerHighest: AppColors.accentDark,
      onSurfaceVariant: AppColors.mutedForegroundDark,
      outline: AppColors.borderDark,
      outlineVariant: AppColors.inputDark,
      error: AppColors.destructive,
      onError: AppColors.destructiveForeground,
      surfaceContainer: AppColors.mutedDark,
    ),
    cardTheme: CardTheme(
      color: AppColors.cardDark,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
      shadowColor: Colors.black.withValues(alpha: 0.1),
      surfaceTintColor: Colors.transparent,
    ),
    cardColor: AppColors.cardDark,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.cardDark,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.foregroundDark),
      titleTextStyle: TextStyle(
        color: AppColors.foregroundDark,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6.0),
        borderSide: BorderSide(color: AppColors.borderDark, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6.0),
        borderSide: BorderSide(color: AppColors.ring, width: 2.0),
      ),
      filled: true,
      fillColor: AppColors.backgroundDark,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.primaryForeground,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: AppColors.borderDark, width: 1.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
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

  static const double cardElevation = 0;

  // Shadow definitions based on Tailwind CSS
  static List<BoxShadow> get shadowXs => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      offset: const Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get shadowSm => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.10),
      offset: const Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.10),
      offset: const Offset(0, 1),
      blurRadius: 2,
      spreadRadius: -1,
    ),
  ];

  static List<BoxShadow> get shadowMd => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.10),
      offset: const Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.10),
      offset: const Offset(0, 2),
      blurRadius: 4,
      spreadRadius: -1,
    ),
  ];

  static List<BoxShadow> get shadowLg => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.10),
      offset: const Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.10),
      offset: const Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -1,
    ),
  ];

  static List<BoxShadow> get shadowXl => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.10),
      offset: const Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.10),
      offset: const Offset(0, 8),
      blurRadius: 10,
      spreadRadius: -1,
    ),
  ];

  static List<BoxShadow> get shadow2xl => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.25),
      offset: const Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
  ];
}
