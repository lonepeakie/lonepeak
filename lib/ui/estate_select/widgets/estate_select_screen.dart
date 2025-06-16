import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lonepeak/router/routes.dart';
import 'package:lonepeak/ui/core/themes/themes.dart';
import 'package:lonepeak/ui/core/widgets/app_buttons.dart';
import 'package:lonepeak/ui/estate_select/view_models/estate_select_viewmodel.dart';

class EstateSelectScreen extends ConsumerWidget {
  const EstateSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(estateSelectViewModelProvider).logout();
              if (context.mounted) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.go(Routes.login);
                });
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FutureBuilder<String>(
              future: ref.watch(estateSelectViewModelProvider).getDisplayName(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Text(
                    'Error loading display name',
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  );
                } else {
                  return Text(
                    'Welcome, ${snapshot.data}!',
                    style: AppStyles.titleTextLarge(context),
                    textAlign: TextAlign.center,
                  );
                }
              },
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
                    onPressed: () {
                      context.go(
                        '${Routes.estateSelect}${Routes.estateCreate}',
                      );
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
                    isAccent: true,
                    onPressed: () {
                      context.go('${Routes.estateSelect}${Routes.estateJoin}');
                    },
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      context.go(Routes.estateHome);
                    },
                    child: const Text(
                      'Go to Dashboard',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
    required VoidCallback onPressed,
    bool isAccent = false,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor.withAlpha(200),
        borderRadius: BorderRadius.circular(10),
        boxShadow: isDarkMode
            ? [BoxShadow(color: Colors.black.withValues(alpha: 0.3))]
            : [BoxShadow(color: Colors.black12.withValues(alpha: 0.1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            child: Icon(icon, color: theme.colorScheme.primary, size: 30),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          isAccent
              ? AppElevatedAccentButton(
                  buttonText: buttonText,
                  onPressed: onPressed,
                )
              : AppElevatedButton(buttonText: buttonText, onPressed: onPressed),
        ],
      ),
    );
  }
}
