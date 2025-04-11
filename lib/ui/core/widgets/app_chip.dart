import 'package:flutter/material.dart';

class AppChipData {
  final String label;
  final Color color;

  AppChipData({required this.label, required this.color});
}

class AppChip extends StatelessWidget {
  final AppChipData chipData;

  const AppChip({super.key, required this.chipData});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(chipData.label),
      backgroundColor: chipData.color.withAlpha(50),
      labelStyle: TextStyle(
        color: chipData.color,
        fontSize: 13,
        fontWeight: FontWeight.bold,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      side: BorderSide.none,
    );
  }
}

class AppChoiceChip extends StatelessWidget {
  final String labelText;
  final List<AppChipData> chipsdata;
  final String selectedValue;
  final void Function(String selectedLabel) onSelected;

  const AppChoiceChip({
    super.key,
    required this.labelText,
    required this.chipsdata,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          labelText,
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        Wrap(
          spacing: 8.0,
          children:
              chipsdata.map((chip) {
                return ChoiceChip(
                  label: Text(chip.label),
                  selected: selectedValue == chip.label,
                  onSelected: (selected) {
                    if (selected) {
                      onSelected(chip.label);
                    }
                  },
                );
              }).toList(),
        ),
      ],
    );
  }
}
