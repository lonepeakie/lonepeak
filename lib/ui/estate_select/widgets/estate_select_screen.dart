import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lonepeak/router/routes.dart';
import 'package:lonepeak/ui/core/themes/colors.dart';

class EstateSelectScreen extends StatelessWidget {
  const EstateSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Text(
              'Welcome, User!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Choose a path below to get started with managing your estate community.',
              style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildOptionCard(
                    context,
                    icon: Icons.add_circle_outline,
                    title: 'Create a New Estate',
                    subtitle: 'Set up and manage a new estate community',
                    description:
                        'Perfect if you\'re establishing a new estate or community and need to set everything up from scratch.',
                    buttonText: 'Create Estate',
                    buttonColor: AppColors.blue,
                    onPressed: () {
                      context.go(Routes.estateCreate);
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildOptionCard(
                    context,
                    icon: Icons.group_outlined,
                    title: 'Join an Existing Estate',
                    subtitle: 'Join an estate you\'ve been invited to',
                    description:
                        'Use the estate code provided by your administrator to join an existing estate community.',
                    buttonText: 'Join Estate',
                    buttonColor: Colors.white,
                    textColor: AppColors.blue,
                    borderColor: AppColors.blue,
                    onPressed: () {
                      // Navigate to Join Estate screen
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required String buttonText,
    required Color buttonColor,
    Color? textColor,
    Color? borderColor,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blue[70],
            child: Icon(icon, color: AppColors.blue, size: 30),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: textColor ?? Colors.white,
              backgroundColor: buttonColor,
              side:
                  borderColor != null
                      ? BorderSide(color: borderColor)
                      : BorderSide.none,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            onPressed: onPressed,
            child: Text(
              buttonText,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor ?? Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
