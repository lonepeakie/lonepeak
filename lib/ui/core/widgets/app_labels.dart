import 'package:flutter/material.dart';
import 'package:lonepeak/ui/core/themes/themes.dart';

class AppbarTitle extends StatelessWidget {
  final String text;

  const AppbarTitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w500,
        color: Theme.of(context).appBarTheme.titleTextStyle?.color,
      ),
    );
  }
}

class AppInfoField extends StatelessWidget {
  final String label;
  final String value;

  const AppInfoField({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppStyles.labelText(context)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withAlpha(80),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(value, style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}
