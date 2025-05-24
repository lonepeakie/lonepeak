import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lonepeak/domain/models/member.dart';
import 'package:lonepeak/domain/models/role.dart';
import 'package:lonepeak/router/routes.dart';
import 'package:lonepeak/ui/core/widgets/appbar_title.dart';
import 'package:lonepeak/ui/estate_members/view_models/estate_members_viewmodel.dart';
import 'package:lonepeak/ui/core/widgets/member_tile.dart';
import 'package:lonepeak/ui/core/ui_state.dart';

class EstateMembersScreen extends ConsumerStatefulWidget {
  const EstateMembersScreen({super.key});

  @override
  ConsumerState<EstateMembersScreen> createState() =>
      _EstateMembersScreenState();
}

class _EstateMembersScreenState extends ConsumerState<EstateMembersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(estateMembersViewModelProvider.notifier).getMembers(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showMemberActionSheet(BuildContext context, Member member) async {
    final viewModel = ref.read(estateMembersViewModelProvider.notifier);
    final isAdmin = await viewModel.hasAdminPrivileges();

    if (!isAdmin) {
      // Non-admin users shouldn't be able to modify members
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
  }

  Widget _buildMemberActionsSheet(BuildContext context, Member member) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
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

            // Member info
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(0.1),
                child: Text(
                  member.displayName[0],
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(member.displayName),
              subtitle: Text(member.email),
              trailing: Chip(
                label: Text(member.role.name),
                backgroundColor: _getRoleColor(member.role.name),
              ),
            ),
            const Divider(height: 32),

            // Change role option
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.edit),
              title: const Text('Change Role'),
              onTap: () => _showChangeRoleDialog(context, member),
            ),

            // Remove member option
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
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remove Member'),
            content: Text(
              'Are you sure you want to remove ${member.displayName}?',
            ),
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
    final viewModel = ref.read(estateMembersViewModelProvider.notifier);
    await viewModel.updateMemberRole(member.email, newRole);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${member.displayName}\'s role updated to ${newRole.name}',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _removeMember(Member member) async {
    final viewModel = ref.read(estateMembersViewModelProvider.notifier);
    await viewModel.removeMember(member.email);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${member.displayName} removed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.blue;
      case 'president':
        return Colors.teal;
      case 'vice president':
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

  @override
  Widget build(BuildContext context) {
    final viewModelState = ref.watch(estateMembersViewModelProvider);
    final activeMembers =
        ref.watch(estateMembersViewModelProvider.notifier).activeMembers;

    final filteredMembers =
        _searchQuery.isEmpty
            ? activeMembers
            : activeMembers.where((member) {
              final name = member.displayName.toLowerCase();
              final email = member.email.toLowerCase();
              final role = member.role.name.toLowerCase();
              return name.contains(_searchQuery.toLowerCase()) ||
                  email.contains(_searchQuery.toLowerCase()) ||
                  role.contains(_searchQuery.toLowerCase());
            }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const AppbarTitle(text: 'Members'),
        actions: [
          FutureBuilder<bool>(
            future:
                ref
                    .watch(estateMembersViewModelProvider.notifier)
                    .hasAdminPrivileges(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data == true) {
                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.admin_panel_settings),
                      onPressed: () {
                        context.go(
                          '${Routes.estateHome}${Routes.estateMembers}${Routes.estateMembersPending}',
                        );
                      },
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
                        child: Text(
                          ref
                              .watch(estateMembersViewModelProvider.notifier)
                              .pendingMembersCount
                              .toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
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
                      _searchQuery.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                          : null,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (viewModelState is UIStateLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (viewModelState is UIStateFailure) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Error: ${viewModelState.error}'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              ref
                                  .read(estateMembersViewModelProvider.notifier)
                                  .getMembers();
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return filteredMembers.isEmpty
                        ? Center(
                          child: Text(
                            _searchQuery.isEmpty
                                ? 'No members found'
                                : 'No matching members found',
                          ),
                        )
                        : ListView.builder(
                          itemCount: filteredMembers.length,
                          itemBuilder: (context, index) {
                            final member = filteredMembers[index];
                            final roleName = member.role.name;
                            return MemberTile(
                              name: member.displayName,
                              email: member.email,
                              role: roleName,
                              onTap:
                                  () => _showMemberActionSheet(context, member),
                            );
                          },
                        );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
