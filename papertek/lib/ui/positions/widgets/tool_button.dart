import 'package:flutter/material.dart';

class PositionToolButton extends StatelessWidget {
  const PositionToolButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 20),
      tooltip: tooltip,
      onPressed: onPressed,
      color: onPressed != null
          ? Theme.of(context).colorScheme.primary
          : const Color(0xFF3A3F4A),
    );
  }
}
