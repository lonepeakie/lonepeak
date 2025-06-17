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
  final authState = ref.watch(authStateProvider);
  final appState = ref.read(appStateProvider);

  return GoRouter(
    initialLocation: Routes.welcome,
    refreshListenable: authState,
    debugLogDiagnostics: true,
    redirect: (BuildContext context, GoRouterState state) async {
      final isAuthenticated = authState.isAuthenticated;
      final isLoginPage = state.matchedLocation == Routes.login;
      final isWelcomePage = state.matchedLocation == Routes.welcome;

      if (isAuthenticated) {
        if (isLoginPage || isWelcomePage) {
          final estateId = await appState.getEstateId();
          if (estateId != null && estateId.isNotEmpty) {
            return Routes.estateHome;
          } else {
            return Routes.estateSelect;
          }
        }
        return null;
      } else {
        if (!isLoginPage && !isWelcomePage) {
          return Routes.login;
        }
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
              builder: (context, state) {
                final estateId = state.extra as String;
                return EstateMembersScreen(estateId: estateId);
              },
              routes: [
                GoRoute(
                  path: Routes.estateMembersPendingRelative,
                  builder: (context, state) {
                    final estateId = state.extra as String;
                    return PendingMembersScreen(estateId: estateId);
                  },
                ),
              ]),
          GoRoute(
            path: Routes.estateNoticesRelative,
            builder: (context, state) {
              final estateId = state.extra as String;
              return EstateNoticesScreen(estateId: estateId);
            },
          ),
          GoRoute(
            path: Routes.estateTreasuryRelative,
            builder: (context, state) {
              final estateId = state.extra as String;
              return EstateTreasuryScreen(estateId: estateId);
            },
          ),
          GoRoute(
            path: Routes.estateDocumentsRelative,
            builder: (context, state) {
              final estateId = state.extra as String;
              return EstateDocumentsScreen(estateId: estateId);
            },
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
