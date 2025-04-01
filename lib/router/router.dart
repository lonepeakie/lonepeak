import 'package:go_router/go_router.dart';
import 'package:lonepeak/router/routes.dart';
import 'package:lonepeak/ui/dashboard/dash.dart';
import 'package:lonepeak/ui/estate_create/widget/estate_create.dart';
import 'package:lonepeak/ui/estate_select/widgets/estate_select_screen.dart';
import 'package:lonepeak/ui/signin/widgets/sign_in_screen.dart';
import 'package:lonepeak/ui/welcome/widgets/welcome_screen.dart';

GoRouter router = GoRouter(
  initialLocation: Routes.welcome,
  routes: [
    GoRoute(
      path: Routes.signin,
      builder: (context, state) {
        return const SignInScreen();
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
        return const EstateCreate();
      },
    ),
  ],
);
