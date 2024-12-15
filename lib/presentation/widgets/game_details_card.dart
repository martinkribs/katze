import 'package:flutter/material.dart';
import 'package:katze/presentation/pages/game_rules_page.dart';
import 'package:katze/presentation/widgets/game_phase_display.dart';
import 'package:intl/intl.dart';

class GameDetailsCard extends StatelessWidget {
  final Map<String, dynamic> gameData;

  const GameDetailsCard({
    super.key,
    required this.gameData,
  });

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return '';
    try {
      final dateTime = DateTime.parse(dateTimeStr).toLocal();
      return DateFormat('DD.MM.YYYY, HH:mm').format(dateTime);
    } catch (e) {
      return dateTimeStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gameDetails = gameData['gameDetails'];
    final currentUser = gameData['currentUser'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (gameData['status'] == 'in_progress') ...[
              GamePhaseDisplay(isDay: gameDetails['isDay']),
              const SizedBox(height: 16),
            ],
            Text(
              'Game Status: ${gameData['status']}',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Players: ${gameData['playerCount']} / ${gameData['minPlayers']}',
              style: theme.textTheme.titleMedium,
            ),
            if (currentUser['role'] != null)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Your Role: ${currentUser['role']['name']}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (currentUser['role']['description'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        currentUser['role']['description'],
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                    if (currentUser['role']['team'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Team: ${currentUser['role']['team']}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    if (currentUser['role']['can_use_day_action'] == true ||
                        currentUser['role']['can_use_night_action'] ==
                            true) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Can act during: ${_getActionTimes(currentUser['role'])}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            if (gameDetails['startedAt'] != null) ...[
              const SizedBox(height: 8),
              Text('Started: ${_formatDateTime(gameDetails['startedAt'])}'),
            ],
            if (gameDetails['completedAt'] != null) ...[
              const SizedBox(height: 8),
              Text('Completed: ${_formatDateTime(gameDetails['completedAt'])}'),
            ],
            if (gameDetails['winningTeam'] != null) ...[
              const SizedBox(height: 16),
              Text(
                'Winning Team: ${gameDetails['winningTeam']}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            if (gameData['status'] == 'in_progress') ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const GameRulesPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.rule),
                  label: const Text('View Game Rules'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getActionTimes(Map<String, dynamic> role) {
    final List<String> times = [];
    if (role['can_use_day_action'] == true) times.add('Day');
    if (role['can_use_night_action'] == true) times.add('Night');
    return times.join(' & ');
  }
}
