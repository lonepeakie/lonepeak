import 'package:flutter/material.dart';

class UserProfileScreen extends StatelessWidget {
  final String? name;
  final String? email;
  final String? phone;
  final String? estateName;
  final String? profileImageUrl;

  const UserProfileScreen({
    super.key,
    this.name = "Akshay M",
    this.email = "akshay@example.com",
    this.phone = "+91 98765 43210",
    this.estateName = "LonePeak Residency",
    this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // ignore: unused_local_variable
    final isDark = theme.brightness == Brightness.dark;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Avatar
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: profileImageUrl != null
                    ? NetworkImage(profileImageUrl!)
                    : null,
                child: profileImageUrl == null
                    ? const Icon(Icons.person, size: 50, color: Colors.grey)
                    : null,
              ),
            ),

            const SizedBox(height: 16),

            // Name
            Text(
              name ?? "Unnamed User",
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),

            const SizedBox(height: 4),

            // Email / Phone
            Text(
              email ?? phone ?? "No contact info",
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 24),

            // Info Cards
            _InfoCard(
              icon: Icons.email,
              title: "Email",
              value: email ?? "Not Provided",
            ),
            const SizedBox(height: 12),
            _InfoCard(
              icon: Icons.phone,
              title: "Phone",
              value: phone ?? "Not Provided",
            ),
            if (estateName != null) ...[
              const SizedBox(height: 12),
              _InfoCard(
                icon: Icons.home_work,
                title: "Estate Name",
                value: estateName!,
              ),
            ],

            const SizedBox(height: 32),

            // Buttons
            _FullWidthButton(
              title: "Exit Estate",
              backgroundColor: theme.primaryColor,
              icon: Icons.exit_to_app,
              textColor: Colors.white,
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _FullWidthButton(
              title: "Logout",
              backgroundColor: Colors.red,
              icon: Icons.logout,
              textColor: Colors.white,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      color: theme.cardColor,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: theme.primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(value, style: theme.textTheme.bodyLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FullWidthButton extends StatelessWidget {
  final String title;
  final Color backgroundColor;
  final IconData icon;
  final Color textColor;
  final VoidCallback onTap;

  const _FullWidthButton({
    required this.title,
    required this.backgroundColor,
    required this.icon,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 2,
        ),
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
