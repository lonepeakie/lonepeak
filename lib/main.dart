import 'package:flutter/material.dart';
import 'package:lonepeak/router/router.dart';
import 'package:lonepeak/ui/core/themes/colors.dart';
import 'package:lonepeak/ui/welcome/widgets/welcome_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.blue),
      ),
      routerConfig: router,
    );
  }
}
