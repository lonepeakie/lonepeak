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
        backgroundColor: Theme.of(context).colorScheme.primary,
        side: BorderSide.none,
        padding: effectivePadding,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      onPressed: onPressed,
      child: Text(
        buttonText,
        style: const TextStyle(
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
    final theme = Theme.of(context);
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: theme.colorScheme.primary,
        backgroundColor: theme.colorScheme.surface,
        side: BorderSide(color: theme.colorScheme.primary),
        padding: effectivePadding,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      onPressed: onPressed,
      child: Text(
        buttonText,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
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
    final theme = Theme.of(context);
    return TextButton(
      onPressed: onPressed,
      child: Row(
        children: [
          Text(
            buttonText,
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_forward_ios, size: 14),
        ],
      ),
    );
  }
}

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
    final effectiveBackgroundColor = backgroundColor ?? AppColors.primary;
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

class AppTextButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;

  const AppTextButton({
    super.key,
    required this.onPressed,
    required this.buttonText,
    this.textColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding =
        padding ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 20);
    final effectiveTextColor =
        textColor ?? Theme.of(context).colorScheme.primary;

    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: effectiveTextColor,
        padding: effectivePadding,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      onPressed: onPressed,
      child: Text(
        buttonText,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: effectiveTextColor,
        ),
      ),
    );
  }
}
