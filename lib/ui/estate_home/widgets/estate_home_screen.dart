import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lonepeak/domain/models/member.dart';
import 'package:lonepeak/providers/member_provider.dart';
import 'package:lonepeak/router/routes.dart';

class EstateHomeScreen extends ConsumerWidget {
  const EstateHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberState = ref.watch(currentMemberProvider);

    return memberState.when(
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (error, stack) => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Error Loading Member',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(currentMemberProvider);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
      data: (member) {
        if (member == null) {
          return const Scaffold(
            body: Center(child: Text('No member data available')),
          );
        }

        if (member.status != MemberStatus.active) {
          context.go('${Routes.estateSelect}${Routes.estateJoinPending}');
        } else {
          context.go('${Routes.estateHome}${Routes.estateDashboard}');
        }

        return const SizedBox.shrink();
      },
    );
  }
}
