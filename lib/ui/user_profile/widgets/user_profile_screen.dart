import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lonepeak/router/routes.dart';
import 'package:lonepeak/ui/core/ui_state.dart';
import 'package:lonepeak/ui/core/widgets/app_buttons.dart';
import 'package:lonepeak/ui/user_profile/view_models/user_profile_viewmodel.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(userProfileViewModelProvider.notifier).getUserProfile(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userProfileViewModelProvider);
    final user = ref.watch(userProfileViewModelProvider.notifier).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).go(Routes.estateHome),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              state is UIStateLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state is UIStateFailure
                  ? Center(child: Text('Error: ${state.error}'))
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: .1),
                        child:
                            user?.photoUrl != null
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image.network(
                                    user!.photoUrl!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                )
                                : Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        user?.displayName ?? 'User',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      _buildInfoTile(
                        context,
                        'Email',
                        user?.email ?? 'N/A',
                        Icons.email,
                      ),
                      const Divider(),
                      _buildInfoTile(
                        context,
                        'Phone',
                        user?.mobile ?? 'Not provided',
                        Icons.phone,
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton.icon(
                        onPressed: _confirmExitEstate,
                        icon: const Icon(Icons.exit_to_app),
                        label: const Text(
                          'Exit Estate',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _confirmLogout,
                        icon: const Icon(Icons.logout),
                        label: const Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.red),
                          minimumSize: const Size(double.infinity, 48),
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(icon, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.textTheme.bodyMedium?.color?.withValues(
                    alpha: 0.6,
                  ),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Logout',
              style: TextStyle(
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            content: Text(
              'Are you sure you want to logout?',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              AppElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final success =
                      await ref
                          .read(userProfileViewModelProvider.notifier)
                          .logout();
                  if (success && context.mounted) {
                    context.go(Routes.welcome);
                  }
                },
                buttonText: 'Logout',
                backgroundColor: Colors.red,
              ),
            ],
          ),
    );
  }

  void _confirmExitEstate() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Exit Estate',
              style: TextStyle(
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            content: Text(
              'Are you sure you want to exit this estate? You\'ll need to join or create a new estate afterwards.',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              AppElevatedButton(
                onPressed: () async {
                  final success =
                      await ref
                          .read(userProfileViewModelProvider.notifier)
                          .exitEstate();
                  if (success && context.mounted) {
                    context.go(Routes.estateSelect);
                  }
                },
                buttonText: 'Exit',
              ),
            ],
          ),
    );
  }
}
