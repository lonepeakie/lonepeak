import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:lonepeak/ui/signin/view_models/auth_state.dart';
import 'package:lonepeak/ui/signin/view_models/signin_viewmodel.dart';
import 'package:lonepeak/utils/log_printer.dart';

class GoogleSignInButton extends ConsumerWidget {
  GoogleSignInButton({super.key});

  final _log = Logger(printer: AppPrefixPrinter('GoogleSignInButton'));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signInState = ref.watch(signInViewModelProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        children: [
          if (signInState is AuthLoading)
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          if (signInState is AuthFailure)
            const Text(
              'Error signing in with Google',
              style: TextStyle(
                fontSize: 20,
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          if (signInState is AuthSuccess)
            const Text(
              'Signed in successfully',
              style: TextStyle(
                fontSize: 20,
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          OutlinedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.white),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
              ),
            ),
            onPressed: () async {
              _log.i('Google sign-in button pressed');
              ref.read(signInViewModelProvider.notifier).signIn();
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // const Image(
                  //   image: AssetImage("assets/google_logo.png"),
                  //   height: 35.0,
                  // ),
                  const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      'Sign in with Google',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
