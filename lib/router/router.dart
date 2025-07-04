import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lonepeak/providers/app_state_provider.dart';
import 'package:lonepeak/providers/auth_state_provider.dart';
import 'package:lonepeak/router/routes.dart';
import 'package:lonepeak/ui/estate_alerts/widgets/estate_alerts_screen.dart';
import 'package:lonepeak/ui/estate_create/widget/estate_create_screen.dart';
import 'package:lonepeak/ui/estate_home/widgets/estate_home_screen.dart';
import 'package:lonepeak/ui/estate_join/widgets/estate_join_screen.dart';
import 'package:lonepeak/ui/estate_members/widgets/estate_members_screen.dart';
import 'package:lonepeak/ui/estate_members/widgets/pending_members_screen.dart';
import 'package:lonepeak/ui/estate_notices/widgets/estate_notices_screen.dart';
import 'package:lonepeak/ui/estate_select/widgets/estate_select_screen.dart';
import 'package:lonepeak/ui/estate_treasury/widgets/estate_treasury_screen.dart';
import 'package:lonepeak/ui/estate_documents/widgets/estate_documents_screen.dart';
import 'package:lonepeak/ui/login/widgets/login_screen.dart';
import 'package:lonepeak/ui/user_profile/widgets/user_profile_screen.dart';
import 'package:lonepeak/ui/welcome/widgets/welcome_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final routerNotifier = ref.watch(authStateProvider);

  Future<String?> redirect(BuildContext context, GoRouterState state) async {
    final isAuthenticated = routerNotifier.isAuthenticated;
    final isLoginPage = state.matchedLocation == Routes.login;
    final isWelcomePage = state.matchedLocation == Routes.welcome;
    final appState = ref.read(appStateProvider);

    if (isAuthenticated && (isLoginPage || isWelcomePage)) {
      final estateId = await appState.getEstateId();

      if (estateId != null && estateId.isNotEmpty) {
        return Routes.estateHome;
      } else {
        return Routes.estateSelect;
      }
    } else if (!isAuthenticated && !isLoginPage && !isWelcomePage) {
      return Routes.login;
    }
    return null;
  }

  return GoRouter(
    initialLocation: Routes.welcome,
    refreshListenable: routerNotifier,
    redirect: redirect,
    routes: [
      GoRoute(
        path: Routes.login,
        builder: (context, state) {
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: Routes.welcome,
        builder: (context, state) {
          return const WelcomeScreen();
        },
      ),
      GoRoute(
        path: Routes.estateHome,
        builder: (context, state) {
          return const EstateHomeScreen();
        },
        routes: [
          GoRoute(
            path: Routes.estateMembersRelative,
            builder: (context, state) {
              return const EstateMembersScreen();
            },
            routes: [
              GoRoute(
                path: Routes.estateMembersPendingRelative,
                builder: (context, state) {
                  return const PendingMembersScreen();
                },
              ),
            ],
          ),
          GoRoute(
            path: Routes.estateNoticesRelative,
            builder: (context, state) {
              return const EstateNoticesScreen();
            },
          ),
          GoRoute(
            path: Routes.estateTreasuryRelative,
            builder: (context, state) {
              return EstateTreasuryScreen();
            },
          ),
          GoRoute(
            path: Routes.estateDocumentsRelative,
            builder: (context, state) {
              return const EstateDocumentsScreen();
            },
          ),
        ],
      ),
      GoRoute(
        path: Routes.estateSelect,
        builder: (context, state) {
          return const EstateSelectScreen();
        },
        routes: [
          GoRoute(
            path: Routes.estateCreateRelative,
            builder: (context, state) {
              return const EstateCreateScreen();
            },
          ),
          GoRoute(
            path: Routes.estateJoinRelative,
            builder: (context, state) {
              return const EstateJoinScreen();
            },
          ),
        ],
      ),
      GoRoute(
        path: Routes.userProfile,
        builder: (context, state) {
          return const UserProfileScreen();
        },
      ),
      GoRoute(
        path: Routes.alerts,
        builder: (context, state) {
          return const EstateAlertsScreen();
        },
      ),
    ],
  );
});
