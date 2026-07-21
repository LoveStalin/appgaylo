import 'package:flutter/material.dart';

class AccountScreenBackground extends StatelessWidget {
  final Widget child;

  const AccountScreenBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  const Color.fromRGBO(28, 28, 30, 1),
                  const Color.fromRGBO(44, 44, 46, 1),
                ]
              : [Colors.pink.shade50, Colors.pink.shade200],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: child,
        ),
      ),
    );
  }
}
