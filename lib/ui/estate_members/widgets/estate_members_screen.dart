import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
