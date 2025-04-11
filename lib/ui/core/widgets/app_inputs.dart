import 'package:flutter/material.dart';
import 'package:lonepeak/ui/core/themes/themes.dart';

class AppTextInput extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final int? maxLines;
  final bool required;
  final String? errorText;

  const AppTextInput({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.maxLines,
    this.required = false,
    this.errorText,
  });

  @override
  State<AppTextInput> createState() => _AppTextInputState();
}

class _AppTextInputState extends State<AppTextInput> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.labelText,
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: widget.controller,
          maxLines: widget.maxLines,
          validator: (value) {
            if (widget.required && (value == null || value.trim().isEmpty)) {
              return widget.errorText ?? 'This field is required';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: widget.hintText,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.grey, width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: AppColors.blue, width: 2.0),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.red, width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.red, width: 2.0),
            ),
          ),
        ),
      ],
    );
  }
}
