import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:lonepeak/router/routes.dart';
import 'package:lonepeak/ui/signin/view_models/auth_state.dart';
import 'package:lonepeak/ui/signin/view_models/signin_viewmodel.dart';
import 'package:lonepeak/utils/log_printer.dart';

class GoogleSignInButton extends ConsumerWidget {
  GoogleSignInButton({super.key});

  final _log = Logger(printer: AppPrefixPrinter('GoogleSignInButton'));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AuthState>(signInViewModelProvider, (previous, next) {
      if (next is AuthSuccess) {
        context.go(Routes.estateSelect);
      } else if (next is AuthFailure) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Error signing in with Google',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    final _ = ref.watch(signInViewModelProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            GestureDetector(
              onTap: () async {
                _log.i('Google sign-in button pressed');
                ref.read(signInViewModelProvider.notifier).signIn();
              },
              child: SvgPicture.asset(
                'assets/svgs/google_signin_button.svg',
                height: 50.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
