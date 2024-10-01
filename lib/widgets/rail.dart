import 'package:flutter/material.dart';

class CustomFloatingNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<CustomNavItem> items;

  const CustomFloatingNavigation({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(items.length, (index) {
          return buildNavItem(context, items[index], index);
        }),
      ),
    );
  }

  Widget buildNavItem(BuildContext context, CustomNavItem item, int index) {
    final isSelected = index == selectedIndex;
    return InkWell(
      key: item.key, // Use the GlobalKey from CustomNavItem
      onTap: () => onDestinationSelected(index),
      child: Container(
        width: 64,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.64),
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(height: 4),
              Text(
                item.label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class CustomNavItem {
  final IconData icon;
  final String label;
  final Key? key;

  const CustomNavItem({
    required this.icon,
    required this.label,
    this.key,
  });
}