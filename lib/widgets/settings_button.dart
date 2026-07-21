import 'package:flutter/material.dart';

class SettingsButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SettingsButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned(
      top: 8,
      right: 8,
      child: SafeArea(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color.fromRGBO(30, 30, 30, 0.6)
                      : const Color.fromRGBO(255, 255, 255, 0.85),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(6),
                child: Icon(
                  Icons.settings,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
