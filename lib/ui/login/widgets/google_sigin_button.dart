import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lonepeak/providers/auth_state_provider.dart';
import 'package:lonepeak/router/routes.dart';
import 'package:lonepeak/ui/login/view_models/login_viewmodel.dart';

class GoogleSignInButton extends ConsumerWidget {
  const GoogleSignInButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            GestureDetector(
              onTap: () async {
                final success =
                    await ref.read(loginViewModelProvider.notifier).logIn();
                await ref.read(authStateProvider).refreshAuthState();
                if (success) {
                  if (context.mounted) {
                    context.go(Routes.estateSelect);
                  }
                } else if (context.mounted) {
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
              },
              //TODO: Change to button
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
