import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color primary = Color(0xFF3B82F6);
  static const Color primaryForeground = Color(0xFFFFFFFF);

  static const Color background = Color(0xFFFFFFFF);
  static const Color foreground = Color(0xFF525252);

  static const Color card = Color(0xFFFFFFFF);
  static const Color cardForeground = Color(0xFF525252);

  static const Color secondary = Color(0xFFF4F4F5);
  static const Color secondaryForeground = Color(0xFF71717A);

  static const Color muted = Color(0xFFFAFAFA);
  static const Color mutedForeground = Color(0xFF8B8B8B);

  static const Color accent = Color(0xFFF1F2F6);
  static const Color accentForeground = Color(0xFF6366F1);

  static const Color border = Color(0xFFE4E4E7);
  static const Color input = Color(0xFFE4E4E7);

  static const Color destructive = Color(0xFFEF4444);
  static const Color destructiveForeground = Color(0xFFFFFFFF);

  static const Color ring = Color(0xFF3B82F6);

  static const Color chart1 = Color(0xFF3B82F6);
  static const Color chart2 = Color(0xFF8B5CF6);
  static const Color chart3 = Color(0xFF7C3AED);
  static const Color chart4 = Color(0xFF6D28D9);
  static const Color chart5 = Color(0xFF6366F1);

  static const Color backgroundDark = Color(0xFF0A0A0A);
  static const Color foregroundDark = Color(0xFFEBEBEB);
  static const Color cardDark = Color(0xFF141414);
  static const Color cardForegroundDark = Color(0xFFEBEBEB);
  static const Color secondaryDark = Color(0xFF404040);
  static const Color secondaryForegroundDark = Color(0xFFEBEBEB);
  static const Color mutedDark = Color(0xFF141414);
  static const Color mutedForegroundDark = Color(0xFFB3B3B3);
  static const Color accentDark = Color(0xFF6366F1);
  static const Color accentForegroundDark = Color(0xFFE1E5FF);
  static const Color borderDark = Color(0xFF5E5E5E);
  static const Color inputDark = Color(0xFF5E5E5E);

  static const Color sidebar = Color(0xFFFAFAFA);
  static const Color sidebarForeground = Color(0xFF525252);
  static const Color sidebarPrimary = Color(0xFF3B82F6);
  static const Color sidebarPrimaryForeground = Color(0xFFFFFFFF);
  static const Color sidebarAccent = Color(0xFFF1F2F6);
  static const Color sidebarAccentForeground = Color(0xFF6366F1);
  static const Color sidebarBorder = Color(0xFFE4E4E7);
  static const Color sidebarRing = Color(0xFF3B82F6);

  static const Color sidebarDark = Color(0xFF333333);
  static const Color sidebarForegroundDark = Color(0xFFEBEBEB);
  static const Color sidebarAccentDark = Color(0xFF6366F1);
  static const Color sidebarAccentForegroundDark = Color(0xFFE1E5FF);
  static const Color sidebarBorderDark = Color(0xFF5E5E5E);

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

  static Color getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.blue;
      case 'president':
        return Colors.teal;
      case 'vicepresident':
        return Colors.orange;
      case 'treasurer':
        return Colors.green;
      case 'member':
        return Colors.cyan;
      case 'secretary':
        return Colors.deepPurpleAccent;
      case 'resident':
        return Colors.blueGrey;
      default:
        return Colors.blueGrey;
    }
  }

  static Color getNoticeTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'urgent':
        return AppColors.red.withValues(alpha: 0.65);
      case 'general':
        return Colors.blue.withValues(alpha: 0.8);
      case 'event':
        return Colors.green.withValues(alpha: 0.7);
      default:
        return Colors.grey.withValues(alpha: 0.5);
    }
  }

  static Color getWebLinkColor(String type) {
    switch (type.toLowerCase()) {
      case 'community':
        return Colors.green.withValues(alpha: 0.65);
      case 'website':
        return Colors.blue.withValues(alpha: 0.8);
      default:
        return Colors.grey.withValues(alpha: 0.5);
    }
  }

  static Color getTransactionTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'maintenance':
        return Colors.blue;
      case 'insurance':
        return Colors.purple;
      case 'utilities':
        return Colors.yellow.shade800;
      case 'rental':
        return Colors.green;
      case 'fees':
        return Colors.teal;
      default:
        return Colors.deepPurpleAccent;
    }
  }
}

abstract final class AppIcons {
  static IconData getNoticeTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'urgent':
        return Icons.warning_amber_outlined;
      case 'general':
        return Icons.info_outline;
      case 'event':
        return Icons.group_outlined;
      default:
        return Icons.help_outline;
    }
  }

  static IconData getWebLinkIcon(String type) {
    switch (type.toLowerCase()) {
      case 'community':
        return Icons.language_outlined;
      case 'website':
        return Icons.forum_outlined;
      default:
        return Icons.link_outlined;
    }
  }

  static IconData getDocumentTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'folder':
        return Icons.folder;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'image':
        return Icons.image;
      case 'word':
        return Icons.description;
      case 'excel':
        return Icons.table_chart;
      default:
        return Icons.insert_drive_file;
    }
  }
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
    cardTheme: CardThemeData(
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
    cardTheme: CardThemeData(
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
