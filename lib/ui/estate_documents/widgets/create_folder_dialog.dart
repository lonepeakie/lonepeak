import 'package:flutter/material.dart';
import 'package:lonepeak/ui/core/themes/themes.dart';
import 'package:lonepeak/ui/core/widgets/app_buttons.dart';
import 'package:lonepeak/ui/core/widgets/app_inputs.dart';

class CreateFolderDialog extends StatefulWidget {
  final Function(String name) onCreateFolder;

  const CreateFolderDialog({super.key, required this.onCreateFolder});

  @override
  State<CreateFolderDialog> createState() => _CreateFolderDialogState();
}

class _CreateFolderDialogState extends State<CreateFolderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create New Folder',
                style: AppStyles.titleTextSmall(context),
              ),
              const SizedBox(height: 16),
              Text(
                'Enter a name of your new folder.',
                style: AppStyles.subtitleText(context),
              ),
              const SizedBox(height: 24),
              AppTextInput(
                controller: _nameController,
                labelText: 'Folder Name',
                hintText: 'e.g., Legal Documents',
                required: true,
                errorText: 'Folder name is required',
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppTextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    buttonText: 'Cancel',
                  ),
                  const SizedBox(width: 16),
                  AppElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        widget.onCreateFolder(_nameController.text);
                        Navigator.of(context).pop();
                      }
                    },
                    buttonText: 'Create',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
