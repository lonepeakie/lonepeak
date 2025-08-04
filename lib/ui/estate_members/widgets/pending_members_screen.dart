import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/domain/models/member.dart';
import 'package:lonepeak/ui/core/widgets/app_labels.dart';
import 'package:lonepeak/providers/member_provider.dart';

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
    // The provider will automatically load members when first watched
  }

  @override
  Widget build(BuildContext context) {
    final pendingMembersState = ref.watch(pendingMembersProvider);

    return Scaffold(
      appBar: AppBar(title: const AppbarTitle(text: 'Pending Requests')),
      body: SafeArea(
        child: pendingMembersState.when(
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
                        ref.invalidate(pendingMembersProvider);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
          data:
              (pendingMembers) =>
                  pendingMembers.isEmpty
                      ? const Center(
                        child: Text('No pending membership requests'),
                      )
                      : ListView.builder(
                        itemCount: pendingMembers.length,
                        itemBuilder: (context, index) {
                          final member = pendingMembers[index];
                          return PendingMemberTile(
                            member: member,
                            onApprove: () async {
                              try {
                                await ref
                                    .read(estateMembersProvider.notifier)
                                    .approveMember(member.email);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${member.displayName} approved',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } catch (error) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: $error'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            onReject: () async {
                              try {
                                await ref
                                    .read(estateMembersProvider.notifier)
                                    .rejectMember(member.email);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${member.displayName} rejected',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } catch (error) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: $error'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                          );
                        },
                      ),
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
            IconButton(
              icon: const Icon(Icons.check_circle_outline),
              color: Colors.green,
              onPressed: onApprove,
              tooltip: 'Approve',
            ),
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
