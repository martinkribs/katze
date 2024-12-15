import 'package:flutter/material.dart';
import 'package:katze/presentation/widgets/game_action_button.dart';

class GameActionList extends StatelessWidget {
  final List<dynamic> actions;
  final Map<String, dynamic> targetPlayer;
  final String gameId;
  final bool isLoading;
  final VoidCallback? onActionComplete;

  const GameActionList({
    super.key,
    required this.actions,
    required this.targetPlayer,
    required this.gameId,
    required this.isLoading,
    this.onActionComplete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Actions',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...actions.map((action) => GameActionButton(
              action: action,
              targetPlayer: targetPlayer,
              gameId: gameId,
              isLoading: isLoading,
              onActionComplete: onActionComplete,
            )),
          ],
        ),
      ),
    );
  }
}
