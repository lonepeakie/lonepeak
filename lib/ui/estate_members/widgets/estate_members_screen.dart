import 'package:flutter/material.dart';
import 'package:lonepeak/ui/core/themes/colors.dart';

class EstateMembersScreen extends StatelessWidget {
  const EstateMembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
        actions: [
          IconButton(icon: const Icon(Icons.person_add), onPressed: () {}),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.admin_panel_settings),
                onPressed: () {},
              ),
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search members...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: const [
                MemberTile(
                  name: 'John Doe',
                  email: 'john@example.com',
                  role: 'Admin',
                  roleColor: Colors.blue,
                ),
                MemberTile(
                  name: 'Jane Smith',
                  email: 'jane@example.com',
                  role: 'Secretary',
                  roleColor: Colors.purple,
                ),
                MemberTile(
                  name: 'Bob Johnson',
                  email: 'bob@example.com',
                  role: 'Resident',
                  roleColor: Colors.grey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
          color: roleColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(role, style: TextStyle(color: roleColor)),
      ),
    );
  }
}
