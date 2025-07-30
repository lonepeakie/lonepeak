import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lonepeak/router/routes.dart';
import 'package:lonepeak/ui/core/themes/themes.dart';
import 'package:lonepeak/ui/core/widgets/app_buttons.dart';

class EstateJoinPendingScreen extends StatelessWidget {
  const EstateJoinPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.access_time,
                        size: 60,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Request Submitted',
                      style: AppStyles.titleTextLarge(context),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your request to join the estate has been sent successfully',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withValues(
                          alpha: 0.7,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Status items
                    _buildStatusItem(
                      context,
                      icon: Icons.check_circle,
                      iconColor: Colors.green,
                      text: 'Request submitted to estate administrator',
                    ),
                    const SizedBox(height: 16),
                    _buildStatusItem(
                      context,
                      icon: Icons.access_time,
                      iconColor: Colors.orange,
                      text: 'Waiting for administrator approval',
                    ),
                    const SizedBox(height: 48),

                    // What happens next section
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'What happens next?',
                            style: AppStyles.titleTextSmall(context),
                          ),
                          const SizedBox(height: 16),
                          _buildNextStepItem(
                            context,
                            text:
                                'The estate administrator will review your request',
                          ),
                          const SizedBox(height: 8),
                          _buildNextStepItem(
                            context,
                            text:
                                'You\'ll receive a notification once approved',
                          ),
                          const SizedBox(height: 8),
                          _buildNextStepItem(
                            context,
                            text: 'You can then access the estate dashboard',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: AppElevatedButton(
                      onPressed:
                          () => GoRouter.of(context).push(Routes.userProfile),
                      buttonText: 'Go to Profile',
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }

  Widget _buildNextStepItem(BuildContext context, {required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }
}
