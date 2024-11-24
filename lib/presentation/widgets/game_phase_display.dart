import 'package:flutter/material.dart';

class GamePhaseDisplay extends StatelessWidget {
  final bool isDay;

  const GamePhaseDisplay({
    super.key,
    required this.isDay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDay ? Colors.orange.withOpacity(0.2) : Colors.indigo.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDay ? Colors.orange : Colors.indigo,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isDay ? Icons.wb_sunny : Icons.nightlight_round,
            color: isDay ? Colors.orange : Colors.indigo,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDay ? 'Day Phase' : 'Night Phase',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isDay ? Colors.orange : Colors.indigo,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isDay ? '7:30 AM - 7:30 PM' : '7:30 PM - 7:30 AM',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDay ? Colors.orange : Colors.indigo,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
