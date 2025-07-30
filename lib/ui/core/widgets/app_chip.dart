import 'package:flutter/material.dart';

class AppChip extends StatelessWidget {
  final String label;
  final Color color;

  const AppChip({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: color.withAlpha(50),
      labelStyle: TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      side: BorderSide.none,
    );
  }
}

class AppChoiceChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final void Function(bool) onSelected;

  const AppChoiceChip({
    super.key,
    required this.label,
    required this.color,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
      selected: selected,
      backgroundColor: color.withAlpha(50),
      selectedColor: color.withAlpha(50),
      padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      side: BorderSide.none,
      onSelected: onSelected,
    );
  }
}
