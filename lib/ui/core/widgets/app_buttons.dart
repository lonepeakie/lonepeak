import 'package:flutter/material.dart';
import 'package:lonepeak/ui/core/themes/themes.dart';

class AppElevatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;
  final EdgeInsetsGeometry? padding;

  const AppElevatedButton({
    super.key,
    required this.onPressed,
    required this.buttonText,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding =
        padding ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 20);
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: AppColors.blue,
        side: BorderSide.none,
        padding: effectivePadding,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      onPressed: onPressed,
      child: Text(
        buttonText,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

class AppElevatedAccentButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;
  final EdgeInsetsGeometry? padding;

  const AppElevatedAccentButton({
    super.key,
    required this.onPressed,
    required this.buttonText,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding =
        padding ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 20);
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: AppColors.blue,
        backgroundColor: Colors.white,
        side: BorderSide(color: AppColors.blue),
        padding: effectivePadding,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      onPressed: onPressed,
      child: Text(
        buttonText,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.blue,
        ),
      ),
    );
  }
}

class AppTextArrowButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;

  const AppTextArrowButton({
    super.key,
    required this.onPressed,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Row(
        children: [
          Text(
            'View All',
            style: TextStyle(
              color: AppColors.black.withAlpha(170),
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.black),
        ],
      ),
    );
  }
}

// ...existing code...

class AppButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? textColor;

  const AppButton({
    super.key,
    required this.onPressed,
    required this.buttonText,
    this.padding,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding =
        padding ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 20);
    final effectiveBackgroundColor = backgroundColor ?? AppColors.blue;
    final effectiveTextColor = textColor ?? Colors.white;

    return TextButton(
      style: ButtonStyle(
        padding: WidgetStateProperty.all(effectivePadding),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        backgroundColor: WidgetStateProperty.all(effectiveBackgroundColor),
        foregroundColor: WidgetStateProperty.all(effectiveTextColor),
        // Remove elevation
        elevation: WidgetStateProperty.all(0),
        // Add minimumSize to ensure consistent sizing with other buttons
        minimumSize: WidgetStateProperty.all(const Size(64, 36)),
      ),
      onPressed: onPressed,
      child: Text(
        buttonText,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: effectiveTextColor,
        ),
      ),
    );
  }
}
