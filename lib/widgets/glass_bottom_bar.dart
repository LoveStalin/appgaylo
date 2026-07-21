import 'dart:ui';
import 'package:flutter/material.dart';

class GlassBottomBar extends StatelessWidget {
  final VoidCallback? onTap;

  final String text;

  const GlassBottomBar({
    super.key,
    required this.onTap,
    this.text = "Nhấn để tiếp tục",
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),

        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),

          child: Material(
            color: Colors.white.withValues(alpha: 0.12),

            child: InkWell(
              onTap: onTap,

              child: Container(
                height: 64,

                alignment: Alignment.center,

                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),

                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
