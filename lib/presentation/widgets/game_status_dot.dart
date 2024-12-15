import 'package:flutter/material.dart';

class GameStatusDot extends StatelessWidget {
  final String? status;
  final double size;

  const GameStatusDot({
    super.key,
    required this.status,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    Color dotColor;
    String tooltip;

    switch (status?.toLowerCase()) {
      case 'pending':
        dotColor = Colors.orange;
        tooltip = 'Pending';
        break;
      case 'in_progress':
        dotColor = Colors.green;
        tooltip = 'In Progress';
        break;
      case 'completed':
        dotColor = Colors.blue;
        tooltip = 'Completed';
        break;
      default:
        dotColor = Colors.grey;
        tooltip = 'Unknown';
    }

    return Tooltip(
      message: tooltip,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: dotColor,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
