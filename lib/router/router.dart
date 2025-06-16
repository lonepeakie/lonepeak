// lib/router/router.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lonepeak/providers/app_state_provider.dart';
import 'package:lonepeak/providers/auth_state_provider.dart';
import 'package:lonepeak/router/routes.dart';
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
import 'package:lonepeak/ui/user_profile/widgets/user_profile_screen_args.dart';
import 'package:lonepeak/ui/welcome/widgets/welcome_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  // NOTE: This pattern is correct. We watch authState to trigger rebuilds.
  final authState = ref.watch(authStateProvider);
  final appState = ref.read(appStateProvider);

  return GoRouter(
    initialLocation: Routes.welcome,
    // NOTE: This correctly listens for changes in your auth state.
    refreshListenable: authState,
    debugLogDiagnostics: true,

    // FIX: The entire redirect logic is replaced with a more robust version.
    redirect: (BuildContext context, GoRouterState state) async {
      final isAuthenticated = authState.isAuthenticated;
      final isLoginPage = state.matchedLocation == Routes.login;
      final isWelcomePage = state.matchedLocation == Routes.welcome;

      // Case 1: User is authenticated
      if (isAuthenticated) {
        // If they are on the login or welcome page, they need to be moved.
        if (isLoginPage || isWelcomePage) {
          final estateId = await appState.getEstateId();
          if (estateId != null && estateId.isNotEmpty) {
            return Routes.estateHome;
          } else {
            return Routes.estateSelect;
          }
        }
        // CRITICAL FIX: If authenticated and NOT on login/welcome (e.g., they
        // are on /user-profile), do NOTHING. Return null to let them stay.
        // This prevents the user from being kicked out of the profile screen.
        return null;
      }
      // Case 2: User is NOT authenticated
      else {
        // If they are trying to access a protected page, redirect to login.
        if (!isLoginPage && !isWelcomePage) {
          return Routes.login;
        }
        // If they are already on a public page (login/welcome), let them stay.
        return null;
      }
    },
    routes: [
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: Routes.estateHome,
        builder: (context, state) => const EstateHomeScreen(),
        routes: [
          GoRoute(
            path: Routes.estateMembersRelative,
            builder: (context, state) => const EstateMembersScreen(),
            routes: [
              GoRoute(
                path: Routes.estateMembersPendingRelative,
                builder: (context, state) => const PendingMembersScreen(),
              ),
            ],
          ),
          GoRoute(
            path: Routes.estateNoticesRelative,
            builder: (context, state) => const EstateNoticesScreen(),
          ),
          GoRoute(
            path: Routes.estateTreasuryRelative,
            builder: (context, state) => const EstateTreasuryScreen(),
          ),
          GoRoute(
            path: Routes.estateDocumentsRelative,
            builder: (context, state) => const EstateDocumentsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: Routes.estateSelect,
        builder: (context, state) => const EstateSelectScreen(),
        routes: [
          GoRoute(
            path: Routes.estateCreateRelative,
            builder: (context, state) => const EstateCreateScreen(),
          ),
          GoRoute(
            path: Routes.estateJoinRelative,
            builder: (context, state) => const EstateJoinScreen(),
          ),
        ],
      ),
      GoRoute(
        path: Routes.userProfile,
        builder: (context, state) {
          final args = state.extra as UserProfileScreenArgs;
          return UserProfileScreen(
            args: args,
          );
        },
      ),
    ],
  );
});
