import 'package:flutter/material.dart';
import 'package:katze/presentation/pages/game_action_page.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';

class PlayerList extends StatelessWidget {
  final List<dynamic> players;
  final Map<String, dynamic> currentUser;
  final String gameId;
  final String gameStatus;
  final bool isVotingPhase;
  final Map<String, dynamic>? gameDetails;

  const PlayerList({
    super.key,
    required this.players,
    required this.currentUser,
    required this.gameId,
    required this.gameStatus,
    required this.isVotingPhase,
    this.gameDetails,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isGameStarted = gameStatus == 'in_progress';
    final bool isDay = gameDetails?['isDay'] ?? true;
    final actionTypes =
        context.watch<GameProvider>().roleActionTypes?['action_types'] ?? [];

    // Check if user can perform actions
    final bool canPerformActions = isGameStarted &&
        !currentUser['isGameMaster'] &&
        currentUser['status']['user'] == 'alive' &&
        actionTypes.isNotEmpty;

    // Check if actions are allowed based on time
    final bool canActNow = canPerformActions &&
        ((isDay &&
                actionTypes
                    .any((action) => action['can_use_day_action'] == true)) ||
            (!isDay &&
                actionTypes
                    .any((action) => action['can_use_night_action'] == true)));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Players',
                  style: theme.textTheme.titleLarge,
                ),
                if (isVotingPhase || canActNow) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isVotingPhase
                          ? theme.primaryColor.withOpacity(0.1)
                          : Colors.blue.withOpacity(0.1),
                      border: Border.all(
                        color: isVotingPhase ? theme.primaryColor : Colors.blue,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isVotingPhase
                              ? Icons.how_to_vote
                              : Icons.play_circle_outline,
                          color:
                              isVotingPhase ? theme.primaryColor : Colors.blue,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isVotingPhase ? 'Voting Phase' : 'Actions Available',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isVotingPhase
                                ? theme.primaryColor
                                : Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: players.length,
              itemBuilder: (context, index) {
                final player = players[index];
                final bool isCurrentUser = player['id'] == currentUser['id'];
                final bool canTarget = (isVotingPhase || canActNow) &&
                    !isCurrentUser &&
                    player['status']['user'] == 'alive';

                // Get available actions for current phase
                final availableActions = isVotingPhase
                    ? [
                        {'name': 'Vote', 'id': 'vote'}
                      ]
                    : actionTypes
                        .where((action) => isDay
                            ? action['can_use_day_action'] == true
                            : action['can_use_night_action'] == true)
                        .toList();

                return Container(
                  decoration: BoxDecoration(
                    color: isCurrentUser
                        ? theme.primaryColor.withOpacity(0.1)
                        : canTarget
                            ? Colors.blue.withOpacity(0.05)
                            : null,
                    borderRadius: BorderRadius.circular(8),
                    border: canTarget
                        ? Border.all(color: Colors.blue.withOpacity(0.3))
                        : null,
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: Icon(
                      Icons.person,
                      color: isCurrentUser ? theme.primaryColor : null,
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            player['name'] ?? '',
                            style: TextStyle(
                              fontWeight:
                                  isCurrentUser ? FontWeight.bold : null,
                              color: isCurrentUser ? theme.primaryColor : null,
                              decoration: player['isGameMaster']
                                  ? TextDecoration.underline
                                  : null,
                              decorationThickness: 2,
                            ),
                          ),
                        ),
                        if (isCurrentUser)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.primaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'YOU',
                              style: TextStyle(
                                color: theme.colorScheme.onPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (player['role'] != null &&
                            player['role']['name'] != 'Hidden' &&
                            (gameStatus == 'completed'))
                          Text('Role: ${player['role']['name']}'),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: player['status']['user'] == 'alive'
                                ? Colors.green
                                : Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            player['status']['user'].toUpperCase(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: canTarget && availableActions.isNotEmpty
                        ? PopupMenuButton<Map<String, dynamic>>(
                            icon: const Icon(Icons.play_circle_outline),
                            onSelected: (action) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => GameActionPage(
                                    gameId: gameId,
                                    targetPlayer: player,
                                    availableActions: [action],
                                  ),
                                ),
                              );
                            },
                            itemBuilder: (context) => availableActions
                                .map((action) => PopupMenuItem(
                                      value: action,
                                      child: Text(action['name']),
                                    ))
                                .toList(),
                          )
                        : null,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
