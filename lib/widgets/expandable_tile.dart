import 'package:flutter/material.dart';

class ExpandableTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const ExpandableTile({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
      children: [child],
    );
  }
}