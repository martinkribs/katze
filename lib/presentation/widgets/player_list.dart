import 'package:flutter/material.dart';
import 'package:katze/presentation/pages/game_action_page.dart';
import 'package:provider/provider.dart';
import '../providers/game_action_provider.dart';

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

  Future<void> _confirmKick(BuildContext context, Map<String, dynamic> player) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Kick Player'),
          content: Text('Are you sure you want to kick ${player['name']}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Kick',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        final gameActionProvider = context.read<GameActionProvider>();
        await gameActionProvider.kickPlayer(gameId, player['id'].toString());
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${player['name']} has been kicked from the game')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to kick player: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isGameStarted = gameStatus == 'in_progress';
    final bool isDay = gameDetails?['isDay'] ?? true;
    final actionTypes =
        context.watch<GameActionProvider>().roleActionTypes?['action_types'] ?? [];

    // Check if user can perform actions
    final bool canPerformActions = isGameStarted &&
        currentUser['status']['user'] == 'alive' &&
        actionTypes.isNotEmpty;

    // Check if actions are allowed based on time
    final bool canActNow = canPerformActions &&
        ((isDay &&
                actionTypes.any((action) => action['is_day_action'] == true)) ||
            (!isDay &&
                actionTypes.any((action) => action['is_day_action'] == false)));

    final bool isGameMaster = currentUser['isGameMaster'] == true;
    final bool isPending = gameStatus == 'pending';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Players',
                  style: theme.textTheme.titleLarge,
                ),
                if (isVotingPhase || canActNow) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
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
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isVotingPhase ? 'Voting Phase' : 'Actions Available',
                          style: theme.textTheme.titleMedium?.copyWith(
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
                            ? action['is_day_action'] == true
                            : action['is_day_action'] == false)
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
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isGameMaster && isPending && !isCurrentUser && !player['isGameMaster'])
                          IconButton(
                            icon: const Icon(Icons.person_remove),
                            color: Colors.red,
                            onPressed: () => _confirmKick(context, player),
                            tooltip: 'Kick Player',
                          ),
                        if (canTarget && availableActions.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.play_circle_outline, size: 30),
                            color: Colors.blue,
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => GameActionPage(
                                    gameId: gameId,
                                    targetPlayer: player,
                                    availableActions: availableActions,
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
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
