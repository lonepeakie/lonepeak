import 'package:flutter/material.dart';

class AppbarTitle extends StatelessWidget {
  final String text;

  const AppbarTitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w500,
        color: Theme.of(context).appBarTheme.titleTextStyle?.color,
      ),
    );
  }
}
