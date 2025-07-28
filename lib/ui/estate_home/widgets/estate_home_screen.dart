import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/domain/models/member.dart';
import 'package:lonepeak/ui/core/ui_state.dart';
import 'package:lonepeak/ui/estate_dashboard/widgets/estate_dashboard_screen.dart';
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
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.pending, size: 64, color: Colors.orange),
              const SizedBox(height: 16),
              const Text(
                'Membership Pending',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your membership is pending approval from the estate admin.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return const Scaffold(body: EstateDashboardScreen());
  }
}
