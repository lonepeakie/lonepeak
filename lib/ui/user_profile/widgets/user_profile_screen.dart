import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lonepeak/router/routes.dart';
import 'package:lonepeak/ui/core/themes/themes.dart';
import 'package:lonepeak/ui/core/ui_state.dart';
import 'package:lonepeak/ui/core/widgets/app_buttons.dart';
import 'package:lonepeak/ui/core/widgets/app_labels.dart';
import 'package:lonepeak/ui/user_profile/view_models/user_profile_viewmodel.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  bool _isEditingDisplayName = false;
  final TextEditingController _displayNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(userProfileViewModelProvider.notifier).getUserProfile(),
    );
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userProfileViewModelProvider);
    final user = ref.watch(userProfileViewModelProvider.notifier).user;
    final estate = ref.watch(userProfileViewModelProvider.notifier).estate;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
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
                  : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person,
                                size: 24,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Profile',
                                    style: AppStyles.titleTextLarge(
                                      context,
                                    ).copyWith(fontSize: 28),
                                  ),
                                  Text(
                                    'Manage your account settings',
                                    style: AppStyles.subtitleText(
                                      context,
                                    ).copyWith(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        _buildSection(
                          context,
                          title: 'Personal Information',
                          subtitle: 'Your personal account information',
                          hasEditButton: true,
                          child: Column(
                            children: [
                              const SizedBox(height: 16),
                              Center(
                                child: Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 40,
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                      child:
                                          user?.photoUrl != null
                                              ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(40),
                                                child: Image.network(
                                                  user!.photoUrl!,
                                                  width: 80,
                                                  height: 80,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                              : const Text(
                                                'f',
                                                style: TextStyle(
                                                  fontSize: 28,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              _buildEditableDisplayNameField(),
                              const SizedBox(height: 16),

                              AppInfoField(
                                label: 'Email Address',
                                value: user?.email ?? 'N/A',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        _buildSection(
                          context,
                          title: 'Current Estate',
                          subtitle: 'The estate you are currently managing',
                          hasEditButton: false,
                          isEstateSection: true,
                          child: Column(
                            children: [
                              const SizedBox(height: 24),

                              AppInfoField(
                                label: 'Estate Name',
                                value: estate?.name ?? 'No Estate',
                              ),
                              const SizedBox(height: 16),

                              AppInfoField(
                                label: 'Address',
                                value:
                                    estate?.displayAddress ?? 'Unknown Address',
                              ),
                              const SizedBox(height: 24),

                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: _confirmExitEstate,
                                  icon: const Icon(Icons.exit_to_app),
                                  label: const Text(
                                    'Exit Estate',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                    side: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline
                                          .withValues(alpha: 0.5),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        _buildSection(
                          context,
                          title: 'Account Actions',
                          subtitle: 'Manage your account and session',
                          hasEditButton: false,
                          isEstateSection: false,
                          child: Column(
                            children: [
                              const SizedBox(height: 24),

                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: _confirmLogout,
                                  icon: const Icon(Icons.exit_to_app),
                                  label: const Text(
                                    'Logout',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: FilledButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: AppColors.red,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool hasEditButton,
    required Widget child,
    bool isEstateSection = false,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isDarkMode
                  ? theme.colorScheme.outline.withValues(alpha: 0.3)
                  : theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppStyles.titleTextMedium(context)),
                    Text(subtitle, style: AppStyles.subtitleText(context)),
                  ],
                ),
              ),
              if (hasEditButton)
                IconButton(
                  onPressed: () => _toggleEditMode(),
                  icon: Icon(
                    _isEditingDisplayName ? Icons.check : Icons.edit,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    padding: const EdgeInsets.all(8),
                  ),
                ),
            ],
          ),
          child,
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
                child: Text('Cancel', style: TextStyle(color: Colors.white)),
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
                backgroundColor: AppColors.red,
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
                child: Text('Cancel', style: TextStyle(color: Colors.white)),
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

  Widget _buildEditableDisplayNameField() {
    final user = ref.watch(userProfileViewModelProvider.notifier).user;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Full Name', style: AppStyles.labelText(context)),
        const SizedBox(height: 8),
        _isEditingDisplayName
            ? TextField(
              controller: _displayNameController,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.words,
            )
            : Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                user?.displayName ?? 'N/A',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
      ],
    );
  }

  void _toggleEditMode() async {
    final user = ref.read(userProfileViewModelProvider.notifier).user;

    if (!_isEditingDisplayName) {
      _displayNameController.text = user?.displayName ?? '';
      setState(() {
        _isEditingDisplayName = true;
      });
    } else {
      final newDisplayName = _displayNameController.text.trim();
      if (newDisplayName.isNotEmpty && newDisplayName != user?.displayName) {
        final success = await ref
            .read(userProfileViewModelProvider.notifier)
            .update(displayName: newDisplayName);

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Display name updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (mounted) {
          final errorMessage =
              ref.read(userProfileViewModelProvider) is UIStateFailure
                  ? (ref.read(userProfileViewModelProvider) as UIStateFailure)
                      .error
                  : 'Failed to update display name';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
          );
          _displayNameController.text = user?.displayName ?? '';
        }
      }

      setState(() {
        _isEditingDisplayName = false;
      });
    }
  }
}
