import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/ui/core/themes/colors.dart';
import 'package:lonepeak/ui/estate_dashboard/widgets/estate_dashboard_screen.dart';
import 'package:lonepeak/ui/estate_members/widgets/estate_members_screen.dart';
import 'package:lonepeak/ui/estate_notices/widgets/estate_notices_screen.dart';

class EstateHomeScreen extends ConsumerStatefulWidget {
  const EstateHomeScreen({super.key});

  @override
  ConsumerState<EstateHomeScreen> createState() => _EstateHomeState();
}

class _EstateHomeState extends ConsumerState<EstateHomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   elevation: 0,
      //   actions: [
      //     IconButton(
      //       icon: Icon(Icons.logout, color: Colors.black.withAlpha(128)),
      //       onPressed: () async {
      //         await ref.read(estateSelectViewModelProvider).logout();
      //         await ref.read(authStateProvider).refreshAuthState();
      //         if (context.mounted) {
      //           WidgetsBinding.instance.addPostFrameCallback((_) {
      //             context.go(Routes.login);
      //           });
      //         }
      //       },
      //     ),
      //   ],
      // ),
      body: _getScreenForIndex(_selectedIndex),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          iconSize: 20.0,
          selectedItemColor: AppColors.blue,
          selectedFontSize: 12.0,
          unselectedFontSize: 12.0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Members'),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Notices',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder),
              label: 'Documents',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet),
              label: 'Treasury',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }

  Widget _getScreenForIndex(int index) {
    switch (index) {
      case 0:
        return EstateDashboardScreen();
      case 1:
        return EstateMembersScreen();
      case 2:
        return EstateNoticesScreen();
      default:
        return EstateDashboardScreen();
    }
  }
}
