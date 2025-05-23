import 'package:flutter/material.dart';
import 'package:lonepeak/domain/models/document.dart';
import 'package:lonepeak/ui/core/themes/themes.dart';
import 'package:lonepeak/ui/core/widgets/app_buttons.dart';

class DocumentPermissionsDialog extends StatefulWidget {
  final Document document;
  final void Function(DocumentPermissions) onSave;

  const DocumentPermissionsDialog({
    Key? key,
    required this.document,
    required this.onSave,
  }) : super(key: key);

  @override
  State<DocumentPermissionsDialog> createState() =>
      _DocumentPermissionsDialogState();
}

class _DocumentPermissionsDialogState extends State<DocumentPermissionsDialog> {
  late DocumentPermissions _permissions;

  @override
  void initState() {
    super.initState();
    // Create a copy of the permissions
    _permissions = DocumentPermissions(
      usersWithViewAccess: List.from(
        widget.document.permissions.usersWithViewAccess,
      ),
      usersWithEditAccess: List.from(
        widget.document.permissions.usersWithEditAccess,
      ),
      usersWithUploadAccess: List.from(
        widget.document.permissions.usersWithUploadAccess,
      ),
      usersWithDeleteAccess: List.from(
        widget.document.permissions.usersWithDeleteAccess,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Document Permissions',
              style: AppStyles.titleTextSmall(context),
            ),
            const SizedBox(height: 8),
            Text(
              'Control who can access "${widget.document.name}"',
              style: AppStyles.subtitleText(context),
            ),
            const SizedBox(height: 24),

            // View permission
            _PermissionSwitch(
              label: 'Everyone can view',
              value: _permissions.usersWithViewAccess.contains('*'),
              onChanged: (value) {
                setState(() {
                  if (value) {
                    _permissions.usersWithViewAccess.clear();
                    _permissions.usersWithViewAccess.add('*');
                  } else {
                    _permissions.usersWithViewAccess.remove('*');
                    // Add the creator to maintain at least one user with access
                    if (widget.document.metadata?.createdBy != null) {
                      _permissions.usersWithViewAccess.add(
                        widget.document.metadata!.createdBy!,
                      );
                    }
                  }
                });
              },
            ),

            // Edit permission
            _PermissionSwitch(
              label: 'Everyone can edit',
              value: _permissions.usersWithEditAccess.contains('*'),
              onChanged: (value) {
                setState(() {
                  if (value) {
                    _permissions.usersWithEditAccess.clear();
                    _permissions.usersWithEditAccess.add('*');
                  } else {
                    _permissions.usersWithEditAccess.remove('*');
                    // Add the creator to maintain at least one user with access
                    if (widget.document.metadata?.createdBy != null) {
                      _permissions.usersWithEditAccess.add(
                        widget.document.metadata!.createdBy!,
                      );
                    }
                  }
                });
              },
            ),

            // Upload permission (only applicable for folders)
            if (widget.document.type == DocumentType.folder)
              _PermissionSwitch(
                label: 'Everyone can upload',
                value: _permissions.usersWithUploadAccess.contains('*'),
                onChanged: (value) {
                  setState(() {
                    if (value) {
                      _permissions.usersWithUploadAccess.clear();
                      _permissions.usersWithUploadAccess.add('*');
                    } else {
                      _permissions.usersWithUploadAccess.remove('*');
                      // Add the creator to maintain at least one user with access
                      if (widget.document.metadata?.createdBy != null) {
                        _permissions.usersWithUploadAccess.add(
                          widget.document.metadata!.createdBy!,
                        );
                      }
                    }
                  });
                },
              ),

            // Delete permission
            _PermissionSwitch(
              label: 'Everyone can delete',
              value: _permissions.usersWithDeleteAccess.contains('*'),
              onChanged: (value) {
                setState(() {
                  if (value) {
                    _permissions.usersWithDeleteAccess.clear();
                    _permissions.usersWithDeleteAccess.add('*');
                  } else {
                    _permissions.usersWithDeleteAccess.remove('*');
                    // Add the creator to maintain at least one user with access
                    if (widget.document.metadata?.createdBy != null) {
                      _permissions.usersWithDeleteAccess.add(
                        widget.document.metadata!.createdBy!,
                      );
                    }
                  }
                });
              },
            ),

            const SizedBox(height: 16),
            Divider(),
            const SizedBox(height: 16),

            // Note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Individual user permissions can be managed by an administrator.',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
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
                    widget.onSave(_permissions);
                    Navigator.of(context).pop();
                  },
                  buttonText: 'Save',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PermissionSwitch({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface),
          ),
          const Spacer(),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
