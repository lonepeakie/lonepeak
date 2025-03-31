import 'package:go_router/go_router.dart';
import 'package:lonepeak/router/routes.dart';
import 'package:lonepeak/ui/welcome/widgets/sign_in_screen.dart';
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
  ],
);
