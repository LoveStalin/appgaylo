import 'package:flutter/material.dart';

class AccountTabsBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChanged;

  const AccountTabsBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color.fromRGBO(20, 20, 20, 1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Posts Tab
          _buildTab(
            context,
            index: 0,
            isSelected: selectedIndex == 0,
            isDark: isDark,
            child: SizedBox(
              width: 40,
              height: 28,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(3, (i) {
                      return Container(
                        width: 6,
                        height: 8,
                        decoration: BoxDecoration(
                          color: selectedIndex == 0 ? Colors.pink : Colors.grey,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(3, (i) {
                      return Container(
                        width: 6,
                        height: 8,
                        decoration: BoxDecoration(
                          color: selectedIndex == 0 ? Colors.pink : Colors.grey,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
          // Drafts Tab
          _buildTab(
            context,
            index: 1,
            isSelected: selectedIndex == 1,
            isDark: isDark,
            child: Icon(
              Icons.create,
              color: selectedIndex == 1 ? Colors.pink : Colors.grey,
            ),
          ),
          // Likes Tab
          _buildTab(
            context,
            index: 2,
            isSelected: selectedIndex == 2,
            isDark: isDark,
            child: Icon(
              Icons.favorite_border,
              color: selectedIndex == 2 ? Colors.pink : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(
    BuildContext context, {
    required int index,
    required bool isSelected,
    required bool isDark,
    required Widget child,
  }) {
    return InkWell(
      onTap: () => onTabChanged(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          child,
          const SizedBox(height: 6),
          Container(
            height: 3,
            width: 24,
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark ? Colors.white : Colors.black)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
