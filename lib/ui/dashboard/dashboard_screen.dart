import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lonepeak/providers/auth_state_provider.dart';
import 'package:lonepeak/router/routes.dart';
import 'package:lonepeak/ui/estate_select/view_models/estate_select_viewmodel.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout,
              color: Colors.black.withValues(alpha: 0.5),
            ),
            onPressed: () async {
              await ref.read(estateSelectViewModelProvider).logout();
              await ref.read(authStateProvider).refreshAuthState();
              if (context.mounted) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.go(Routes.login);
                });
              }
            },
          ),
        ],
      ),
      body: Center(child: Text('Hello, this is your dashboard!')),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          // Handle navigation based on index
        },
      ),
    );
  }
}
