import 'package:flutter/material.dart';
import 'package:lonepeak/ui/core/widgets/app_chip.dart';

class MemberTile extends StatelessWidget {
  final String name;
  final String email;
  final String role;
  final EdgeInsetsGeometry? padding;

  const MemberTile({
    super.key,
    required this.name,
    required this.email,
    required this.role,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final Color roleColor = _getRoleColor(role);

    return ListTile(
      contentPadding: padding,
      leading: CircleAvatar(child: Text(name[0])),
      title: Text(name),
      subtitle: Text(email),
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
