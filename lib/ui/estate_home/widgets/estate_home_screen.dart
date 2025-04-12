import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      () => ref.read(estateHomeViewModelProvider.notifier).setUserAndEstateId(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: EstateDashboardScreen());
  }
}
