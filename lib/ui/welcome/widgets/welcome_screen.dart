import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lonepeak/router/routes.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ignore: prefer_const_constructors
              SizedBox(height: 64),
              Row(
                children: [
                  Icon(
                    Icons.home_outlined,
                    color: theme.colorScheme.primary,
                    size: 32,
                  ),
                  // ignore: prefer_const_constructors
                  SizedBox(width: 8),
                  Text(
                    'MyEstate',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.titleLarge?.color,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),
              Text(
                'Manage your estate\ncommunity with ease',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.headlineLarge?.color,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'A comprehensive platform for estate management, designed to simplify community administration and foster collaboration.',
                style: TextStyle(
                  fontSize: 16,
                  color: theme.textTheme.bodyMedium?.color?.withValues(
                    alpha: 0.7,
                  ),
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.go(Routes.login),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Get Started',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 48),
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _FeatureCard(
                    title: 'Document Management',
                    description:
                        'Centralized storage for all estate documents and files.',
                  ),
                  _FeatureCard(
                    title: 'Announcements',
                    description:
                        'Keep everyone in the community informed with notices.',
                  ),
                  _FeatureCard(
                    title: 'Member Directory',
                    description:
                        'Manage residents and committee members with ease.',
                  ),
                  _FeatureCard(
                    title: 'Financial Tracking',
                    description:
                        'Record and monitor income, expenses, and budget.',
                  ),
                ],
              ),
              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String description;

  const _FeatureCard({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.titleMedium?.color,
            ),
          ),
          SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
