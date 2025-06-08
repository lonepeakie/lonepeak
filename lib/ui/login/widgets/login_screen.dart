import 'package:flutter/material.dart';
import 'package:lonepeak/ui/login/widgets/google_sigin_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: theme.colorScheme.primary.withValues(
                    alpha: 0.1,
                  ),
                  child: Icon(
                    Icons.home_outlined,
                    color: theme.colorScheme.primary,
                    size: 48,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'MyEstate',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.titleLarge?.color,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Managing communities, simplified.',
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.textTheme.bodyMedium?.color?.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ),
                SizedBox(height: 56),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color:
                            theme.brightness == Brightness.dark
                                ? Colors.black.withValues(alpha: 0.2)
                                : Colors.grey.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(children: [_buildLoginForm()]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Welcome',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.titleLarge?.color,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          'Login / Signup to access your account',
          style: TextStyle(
            fontSize: 14,
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 64),
        GoogleSignInButton(),
      ],
    );
  }
}
