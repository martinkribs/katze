import 'package:flutter/material.dart';

class GamePhaseDisplay extends StatelessWidget {
  final String phase;

  const GamePhaseDisplay({
    super.key,
    required this.phase,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color phaseColor;
    IconData phaseIcon;
    String phaseTitle;
    String phaseTime;

    switch (phase) {
      case 'preparation':
        phaseColor = Colors.blue;
        phaseIcon = Icons.hourglass_empty;
        phaseTitle = 'Preparation Phase';
        phaseTime = 'Game is preparing to start';
        break;
      case 'day':
        phaseColor = Colors.orange;
        phaseIcon = Icons.wb_sunny;
        phaseTitle = 'Day Phase';
        phaseTime = '7:30 AM - 7:30 PM';
        break;
      case 'night':
        phaseColor = Colors.indigo;
        phaseIcon = Icons.nightlight_round;
        phaseTitle = 'Night Phase';
        phaseTime = '7:30 PM - 7:30 AM';
        break;
      case 'voting':
        phaseColor = Colors.green;
        phaseIcon = Icons.how_to_vote;
        phaseTitle = 'Voting Phase';
        phaseTime = 'Time to vote!';
        break;
      default:
        phaseColor = Colors.grey;
        phaseIcon = Icons.question_mark;
        phaseTitle = 'Unknown Phase';
        phaseTime = '';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: phaseColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: phaseColor,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            phaseIcon,
            color: phaseColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  phaseTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: phaseColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  phaseTime,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: phaseColor,
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
