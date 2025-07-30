import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/domain/models/member.dart';
import 'package:lonepeak/ui/core/widgets/app_labels.dart';
import 'package:lonepeak/ui/estate_members/view_models/estate_members_viewmodel.dart';
import 'package:lonepeak/ui/core/ui_state.dart';

class PendingMembersScreen extends ConsumerStatefulWidget {
  const PendingMembersScreen({super.key});

  @override
  ConsumerState<PendingMembersScreen> createState() =>
      _PendingMembersScreenState();
}

class _PendingMembersScreenState extends ConsumerState<PendingMembersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(estateMembersViewModelProvider.notifier).getMembers(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModelState = ref.watch(estateMembersViewModelProvider);
    final viewModel = ref.watch(estateMembersViewModelProvider.notifier);

    final pendingMembers = viewModel.pendingMembers;

    return Scaffold(
      appBar: AppBar(title: const AppbarTitle(text: 'Pending Requests')),
      body: SafeArea(
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
              return pendingMembers.isEmpty
                  ? const Center(child: Text('No pending membership requests'))
                  : ListView.builder(
                    itemCount: pendingMembers.length,
                    itemBuilder: (context, index) {
                      final member = pendingMembers[index];
                      return PendingMemberTile(
                        member: member,
                        onApprove: () async {
                          await viewModel.approveMember(member.email);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${member.displayName} approved'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                        onReject: () async {
                          await viewModel.rejectMember(member.email);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${member.displayName} rejected'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      );
                    },
                  );
            }
          },
        ),
      ),
    );
  }
}

class PendingMemberTile extends StatelessWidget {
  final Member member;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const PendingMemberTile({
    super.key,
    required this.member,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    // Extract first letter for the avatar
    final String avatarText =
        member.displayName.isNotEmpty
            ? member.displayName[0].toUpperCase()
            : 'U';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Avatar circle with first letter
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey.shade200,
              child: Text(
                avatarText,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Name and email
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    member.email,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            // Approve button
            IconButton(
              icon: const Icon(Icons.check_circle_outline),
              color: Colors.green,
              onPressed: onApprove,
              tooltip: 'Approve',
            ),
            // Reject button
            IconButton(
              icon: const Icon(Icons.cancel_outlined),
              color: Colors.red,
              onPressed: onReject,
              tooltip: 'Reject',
            ),
          ],
        ),
      ),
    );
  }
}
