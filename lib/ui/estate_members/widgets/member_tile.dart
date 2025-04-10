import 'package:flutter/material.dart';

class MemberTile extends StatelessWidget {
  final String name;
  final String email;
  final String role;
  final Color roleColor;

  const MemberTile({
    super.key,
    required this.name,
    required this.email,
    required this.role,
    required this.roleColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Text(name[0])),
      title: Text(name),
      subtitle: Text(email),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: roleColor.withAlpha(50),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(role, style: TextStyle(color: roleColor)),
      ),
    );
  }
}
