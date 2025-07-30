import 'package:flutter/material.dart';
import 'package:lonepeak/ui/core/widgets/app_chip.dart';

class MemberTile extends StatelessWidget {
  final String name;
  final String? email;
  final String role;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const MemberTile({
    super.key,
    required this.name,
    this.email,
    required this.role,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color roleColor = _getRoleColor(role);
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: padding,
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor:
            theme.brightness == Brightness.dark
                ? theme.colorScheme.primary.withValues(alpha: 0.2)
                : theme.colorScheme.primary.withValues(alpha: 0.1),
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '',
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        name,
        style: TextStyle(
          color: theme.textTheme.titleMedium?.color,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle:
          email != null && email!.isNotEmpty
              ? Text(
                email!,
                style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color?.withValues(
                    alpha: 0.7,
                  ),
                ),
              )
              : null,
      trailing: AppChip(label: role, color: roleColor),
    );
  }
}

Color _getRoleColor(String role) {
  switch (role.toLowerCase()) {
    case 'admin':
      return Colors.blue;
    case 'president':
      return Colors.teal;
    case 'vicepresident':
      return Colors.orange;
    case 'treasurer':
      return Colors.green;
    case 'member':
      return Colors.cyan;
    case 'secretary':
      return Colors.purple;
    case 'resident':
      return Colors.grey;
    default:
      return Colors.grey;
  }
}
