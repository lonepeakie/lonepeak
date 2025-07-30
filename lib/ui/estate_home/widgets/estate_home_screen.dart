import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lonepeak/domain/models/member.dart';
import 'package:lonepeak/router/routes.dart';
import 'package:lonepeak/ui/core/ui_state.dart';
import 'package:lonepeak/ui/estate_home/view_models/estate_home_viewmodel.dart';

class EstateHomeScreen extends ConsumerStatefulWidget {
  const EstateHomeScreen({super.key});

  @override
  ConsumerState<EstateHomeScreen> createState() => _EstateHomeState();
}

class _EstateHomeState extends ConsumerState<EstateHomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(estateHomeViewModelProvider.notifier).getMember(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(estateHomeViewModelProvider);
    final member = ref.watch(estateHomeViewModelProvider.notifier).member;

    if (state is UIStateLoading || member == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (state is UIStateFailure) {
      return Scaffold(
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
                state.error,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(estateHomeViewModelProvider.notifier).getMember();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (member.status != MemberStatus.active) {
      context.go('${Routes.estateSelect}${Routes.estateJoinPending}');
    } else {
      context.go('${Routes.estateHome}${Routes.estateDashboard}');
    }

    return const SizedBox.shrink();
  }
}
