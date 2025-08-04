import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lonepeak/domain/models/estate.dart';
import 'package:lonepeak/domain/models/user.dart';
import 'package:lonepeak/providers/estate_provider.dart';
import 'package:lonepeak/providers/user_profile_provider.dart';
import 'package:lonepeak/router/routes.dart';
import 'package:lonepeak/ui/core/themes/themes.dart';
import 'package:lonepeak/ui/core/widgets/app_buttons.dart';
import 'package:lonepeak/ui/core/widgets/app_cards.dart';
import 'package:lonepeak/ui/core/widgets/app_inputs.dart';
import 'package:lonepeak/ui/core/widgets/app_labels.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  final TextEditingController _displayNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(userProfileProvider.notifier).getUserProfile(),
    );
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProfileProvider);
    final estateState = ref.watch(estateProvider);

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
          child: userState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
            data:
                (user) => estateState.when(
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                  data:
                      (estate) => SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary
                                        .withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    size: 24,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                            _buildPersonalInfoCard(user),
                            const SizedBox(height: 32),
                            _buildEstateCard(estate),
                            const SizedBox(height: 32),
                            _buildAccountActionsCard(),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoCard(User? user) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: AppStyles.cardElevation,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCardHeader(
              title: 'Personal Information',
              icon: Icons.person_outline,
              subtitle: 'Your personal account information',
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: AppColors.primary,
                  ),
                  tooltip: 'Edit',
                  onPressed: () => {_showEditUserBottomSheet(user)},
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child:
                        user?.photoUrl != null
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(40),
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
            const SizedBox(height: 16),
            AppInfoField(
              label: 'Display Name',
              value: user?.displayName ?? 'N/A',
            ),
            const SizedBox(height: 16),
            AppInfoField(label: 'Email Address', value: user?.email ?? 'N/A'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildEstateCard(Estate? currentEstate) {
    // Check if estate is empty or unknown
    if (currentEstate == null ||
        currentEstate.id == null ||
        currentEstate.id!.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: AppStyles.cardElevation,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppCardHeader(
                title: 'Estate Information',
                icon: Icons.business_outlined,
                subtitle: 'Details about your current estate',
              ),
              _buildEmptyEstateState(),
            ],
          ),
        ),
      );
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: AppStyles.cardElevation,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCardHeader(
              title: 'Estate Information',
              icon: Icons.business_outlined,
              subtitle: 'Details about your current estate',
            ),
            const SizedBox(height: 24),
            AppInfoField(
              label: 'Estate Name',
              value:
                  currentEstate.name.isEmpty
                      ? 'Unknown Estate'
                      : currentEstate.name,
            ),
            const SizedBox(height: 16),
            AppInfoField(
              label: 'Address',
              value:
                  currentEstate.displayAddress.isEmpty
                      ? 'Unknown Address'
                      : currentEstate.displayAddress,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _confirmExitEstate,
                icon: const Icon(Icons.exit_to_app),
                label: const Text(
                  'Exit Estate',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                      Theme.of(context).colorScheme.onSurfaceVariant,
                  side: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.5),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyEstateState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      width: double.infinity,
      child: Column(
        children: [
          Icon(Icons.home, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No estate joined yet',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountActionsCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: AppStyles.cardElevation,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCardHeader(
              title: 'Account Actions',
              icon: Icons.manage_accounts_outlined,
              subtitle: 'Manage your account settings',
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _confirmLogout,
                icon: const Icon(Icons.exit_to_app),
                label: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: FilledButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
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
                  await ref.read(userProfileProvider.notifier).signOut();
                  if (context.mounted) {
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
                  await ref.read(userProfileProvider.notifier).leaveEstate();
                  if (context.mounted) {
                    context.go(Routes.estateSelect);
                  }
                },
                buttonText: 'Exit',
              ),
            ],
          ),
    );
  }

  void _showEditUserBottomSheet(User? user) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: user?.displayName);

    showModalBottomSheet<User>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(width: 24),
                            Text(
                              'Edit Personal Details',
                              style: AppStyles.titleTextSmall(context),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                        Center(
                          child: Text(
                            'Edit the details of your profile.',
                            style: AppStyles.subtitleText(context),
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppTextInput(
                          controller: nameController,
                          labelText: 'Display Name',
                          hintText: 'Enter your name',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Display name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            AppElevatedButton(
                              onPressed: () async {
                                if (formKey.currentState?.validate() ?? false) {
                                  final userState = ref.read(
                                    userProfileProvider,
                                  );

                                  userState.whenData((currentUser) async {
                                    if (currentUser != null) {
                                      final updatedUser = User(
                                        displayName: nameController.text.trim(),
                                        email: currentUser.email,
                                        mobile: currentUser.mobile,
                                        photoUrl: currentUser.photoUrl,
                                        estateId: currentUser.estateId,
                                        metadata: currentUser.metadata,
                                      );

                                      await ref
                                          .read(userProfileProvider.notifier)
                                          .updateUserProfile(updatedUser);
                                    }
                                  });

                                  if (!context.mounted) return;
                                  Navigator.of(context).pop();
                                }
                              },
                              buttonText: 'Update',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
    );
  }
}
