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
