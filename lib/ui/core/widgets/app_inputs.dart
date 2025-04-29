import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lonepeak/ui/core/themes/themes.dart';

class AppTextInput extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final int? maxLines;
  final bool required;
  final String? errorText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const AppTextInput({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.maxLines,
    this.required = false,
    this.errorText,
    this.validator,
    this.keyboardType,
  });

  @override
  State<AppTextInput> createState() => _AppTextInputState();
}

class _AppTextInputState extends State<AppTextInput> {
  @override
  Widget build(BuildContext context) {
    final validator =
        widget.validator ??
        (value) {
          if (widget.required && (value == null || value.trim().isEmpty)) {
            return widget.errorText ?? 'This field is required';
          }
          return null;
        };
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
          validator: validator,
          keyboardType: widget.keyboardType,
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

class AppDatePicker extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final bool required;
  final String? errorText;
  final TextInputType? keyboardType;

  const AppDatePicker({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.required = false,
    this.errorText,
    this.keyboardType,
  });

  @override
  State<AppDatePicker> createState() => _AppDatePickerState();
}

class _AppDatePickerState extends State<AppDatePicker> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.controller.text.isNotEmpty) {
      try {
        selectedDate = DateFormat('yyyy-MM-dd').parse(widget.controller.text);
      } catch (e) {
        selectedDate = DateTime.now();
      }
    } else {
      selectedDate = DateTime.now();
      widget.controller.text = DateFormat('yyyy-MM-dd').format(selectedDate);
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        widget.controller.text = DateFormat('yyyy-MM-dd').format(selectedDate);
      });
    }
  }

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
        InkWell(
          onTap: () => selectDate(context),
          child: InputDecorator(
            decoration: InputDecoration(
              hintText: 'Date',
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                const Icon(Icons.calendar_today),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class AppDropdown<T> extends StatelessWidget {
  final String labelText;
  final T value;
  final List<DropdownItem<T>> items;
  final void Function(T?) onChanged;
  final String? Function(T?)? validator;
  final bool required;
  final String? errorText;

  const AppDropdown({
    super.key,
    required this.labelText,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.required = false,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      initialValue: value,
      validator:
          validator ??
          (value) {
            if (required && value == null) {
              return errorText ?? 'Please select a value';
            }
            return null;
          },
      builder: (FormFieldState<T> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              labelText,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: state.hasError ? Colors.red : Colors.grey,
                  width: 1.2,
                ),
              ),
              child: DropdownButton<T>(
                value: state.value,
                isExpanded: true,
                underline: Container(),
                elevation: 1,
                borderRadius: BorderRadius.circular(8),
                icon: const Icon(Icons.keyboard_arrow_down),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                menuMaxHeight: 300, // Limit max height of dropdown
                itemHeight: 48,
                onChanged: (T? newValue) {
                  state.didChange(newValue);
                  onChanged(newValue);
                },
                items:
                    items.map((DropdownItem<T> item) {
                      return DropdownMenuItem<T>(
                        value: item.value,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            item.label,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 8),
                child: Text(
                  state.errorText!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class DropdownItem<T> {
  final T value;
  final String label;

  const DropdownItem({required this.value, required this.label});
}
