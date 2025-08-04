import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lonepeak/domain/models/member.dart';
import 'package:lonepeak/domain/models/role.dart';
import 'package:lonepeak/providers/member_provider.dart';
import 'package:lonepeak/router/routes.dart';
import 'package:lonepeak/ui/core/themes/themes.dart';
import 'package:lonepeak/ui/core/widgets/app_chip.dart';
import 'package:lonepeak/ui/core/widgets/app_labels.dart';
import 'package:lonepeak/ui/core/widgets/app_tiles.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

class EstateMembersScreen extends ConsumerStatefulWidget {
  const EstateMembersScreen({super.key});

  @override
  ConsumerState<EstateMembersScreen> createState() =>
      _EstateMembersScreenState();
}

class _EstateMembersScreenState extends ConsumerState<EstateMembersScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showMemberActionSheet(BuildContext context, Member member) async {
    try {
      final hasAdminAccess =
          await ref.read(currentMemberProvider.notifier).hasAdminPrivileges();
      if (!context.mounted) return;

      if (!hasAdminAccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You need admin privileges to modify members'),
          ),
        );
        return;
      }

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) => _buildMemberActionsSheet(context, member),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error checking admin privileges: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildMemberActionsSheet(BuildContext context, Member member) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: .1),
                child: Text(
                  member.displayName.isNotEmpty
                      ? member.displayName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                member.displayName.isNotEmpty
                    ? member.displayName
                    : 'Unknown User',
              ),
              subtitle: Text(member.email),
              trailing: AppChip(
                label: member.role.name,
                color: AppColors.getRoleColor(member.role.name),
              ),
            ),
            const Divider(height: 32),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.edit),
              title: const Text('Change Role'),
              onTap: () => _showChangeRoleDialog(context, member),
            ),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.person_remove, color: Colors.red),
              title: const Text(
                'Remove Member',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () => _showRemoveMemberConfirmation(context, member),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangeRoleDialog(BuildContext context, Member member) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Change Role'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children:
                    RoleType.values
                        .map(
                          (role) => ListTile(
                            title: Text(role.name),
                            selected: member.role == role,
                            onTap: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              _updateMemberRole(member, role);
                            },
                          ),
                        )
                        .toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  void _showRemoveMemberConfirmation(BuildContext context, Member member) {
    final displayName =
        member.displayName.isNotEmpty ? member.displayName : 'Unknown User';
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remove Member'),
            content: Text('Are you sure you want to remove $displayName?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  _removeMember(member);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Remove'),
              ),
            ],
          ),
    );
  }

  void _updateMemberRole(Member member, RoleType newRole) async {
    final displayName =
        member.displayName.isNotEmpty ? member.displayName : 'Unknown User';

    try {
      await ref
          .read(estateMembersProvider.notifier)
          .updateMemberRole(member.email, newRole);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$displayName\'s role updated to ${newRole.name}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating role: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeMember(Member member) async {
    final displayName =
        member.displayName.isNotEmpty ? member.displayName : 'Unknown User';

    try {
      await ref.read(estateMembersProvider.notifier).removeMember(member.email);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$displayName removed'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing member: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final membersState = ref.watch(estateMembersProvider);
    final memberState = ref.watch(currentMemberProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const AppbarTitle(text: 'Members'),
        actions: [
          memberState.when(
            loading: () => const SizedBox.shrink(),
            error: (error, stack) => const SizedBox.shrink(),
            data:
                (member) => FutureBuilder<bool>(
                  future:
                      ref
                          .read(currentMemberProvider.notifier)
                          .hasAdminPrivileges(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data == true) {
                      return Consumer(
                        builder: (context, ref, _) {
                          final pendingMembersAsync = ref.watch(
                            pendingMembersCountProvider,
                          );
                          return Stack(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.admin_panel_settings),
                                onPressed: () {
                                  GoRouter.of(context).push(
                                    '${Routes.estateHome}${Routes.estateMembers}${Routes.estateMembersPending}',
                                  );
                                },
                              ),
                              pendingMembersAsync.when(
                                loading: () => const SizedBox.shrink(),
                                error:
                                    (error, stack) => const SizedBox.shrink(),
                                data:
                                    (count) =>
                                        count > 0
                                            ? Positioned(
                                              right: 4,
                                              top: 4,
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  4.0,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.shade300,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Text(
                                                  count.toString(),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            )
                                            : const SizedBox.shrink(),
                              ),
                            ],
                          );
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search members...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  suffixIcon:
                      searchQuery.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(searchQueryProvider.notifier).state = '';
                            },
                          )
                          : null,
                ),
                onChanged: (value) {
                  ref.read(searchQueryProvider.notifier).state = value;
                },
              ),
            ),
            Expanded(
              child: membersState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (error, stack) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Error: $error'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              ref.invalidate(estateMembersProvider);
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                data: (allMembers) {
                  final activeMembers =
                      allMembers
                          .where(
                            (member) => member.status == MemberStatus.active,
                          )
                          .toList();

                  final filteredMembers =
                      searchQuery.isEmpty
                          ? activeMembers
                          : activeMembers.where((member) {
                            final name =
                                (member.displayName.isNotEmpty
                                        ? member.displayName
                                        : 'Unknown User')
                                    .toLowerCase();
                            final email = member.email.toLowerCase();
                            final role = member.role.name.toLowerCase();
                            return name.contains(searchQuery.toLowerCase()) ||
                                email.contains(searchQuery.toLowerCase()) ||
                                role.contains(searchQuery.toLowerCase());
                          }).toList();

                  return filteredMembers.isEmpty
                      ? Center(
                        child: Text(
                          searchQuery.isEmpty
                              ? 'No members found'
                              : 'No matching members found',
                        ),
                      )
                      : ListView.builder(
                        itemCount: filteredMembers.length,
                        itemBuilder: (context, index) {
                          final member = filteredMembers[index];
                          final roleName = member.role.name;
                          final displayName =
                              member.displayName.isNotEmpty
                                  ? member.displayName
                                  : 'Unknown User';
                          return MemberTile(
                            name: displayName,
                            email: member.email,
                            role: roleName,
                            onTap:
                                () => {
                                  if (context.mounted)
                                    {_showMemberActionSheet(context, member)},
                                },
                          );
                        },
                      );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
