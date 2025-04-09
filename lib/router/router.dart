import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lonepeak/providers/auth_state_provider.dart';
import 'package:lonepeak/router/routes.dart';
import 'package:lonepeak/ui/dashboard/dash.dart';
import 'package:lonepeak/ui/estate_create/widget/estate_create_screen.dart';
import 'package:lonepeak/ui/estate_select/widgets/estate_select_screen.dart';
import 'package:lonepeak/ui/login/widgets/login_screen.dart';
import 'package:lonepeak/ui/welcome/widgets/welcome_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final routerNotifier = ref.watch(authStateProvider);

  redirect(BuildContext context, GoRouterState state) {
    final isAuthenticated = routerNotifier.isAuthenticated;
    final isLoginPage = state.matchedLocation == Routes.login;
    final isWelcomePage = state.matchedLocation == Routes.welcome;

    if (isAuthenticated && (isLoginPage || isWelcomePage)) {
      return Routes.estateSelect;
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
        path: Routes.dashboard,
        builder: (context, state) {
          return const Dash();
        },
      ),
      GoRoute(
        path: Routes.estateSelect,
        builder: (context, state) {
          return const EstateSelectScreen();
        },
      ),
      GoRoute(
        path: Routes.estateCreate,
        builder: (context, state) {
          return const EstateCreateScreen();
        },
      ),
    ],
  );
});
