import 'package:flutter/material.dart';

class GameRulesPage extends StatelessWidget {
  const GameRulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Rules'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildRuleCard(
              theme,
              title: 'Day/Night Cycle',
              content: 'A day lasts 24 hours and starts/ends at 7:30 AM.\n'
                  '• Day: 7:30 AM – 7:30 PM\n'
                  '• Night: 7:30 PM – 7:30 AM',
            ),
            _buildRuleCard(
              theme,
              title: 'Death Rules',
              content:
                  'When dead, you must completely refrain from participating in the game. '
                  'No comments about the game may be made to living players.',
            ),
            _buildRuleCard(
              theme,
              title: 'Hunger Rule',
              content: 'At least one player must die by murder every 2 weeks. '
                  'This means there can be a maximum of 13 days between two murders.',
            ),
            _buildRuleCard(
              theme,
              title: 'Murder Reporting',
              content:
                  'When committing a murder, the killer (Cat/Serial Killer) must immediately '
                  'report to the game master about the circumstances - Who, Where, When. '
                  'Attempted murder of the traitor must also be reported.',
            ),
            _buildRuleCard(
              theme,
              title: 'Death Reporting',
              content:
                  'If you die from murder, you must inform the game master and write a message '
                  'in the "dead" group that only says "I am dead".',
            ),
            _buildRuleCard(
              theme,
              title: 'Role Rules',
              content:
                  '• It is forbidden to reveal your role or pretend/claim to have a specific role\n'
                  '• Alliances are forbidden (with role-specific exceptions)',
            ),
            _buildRuleCard(
              theme,
              title: 'Voting Rules',
              content: '• Votes take place every Wednesday and Sunday\n'
                  '• They last exactly one day (voting possible all day)\n'
                  '• The first vote after game start is skipped\n'
                  '• Sunday votes must result in a victim\n'
                  '• Wednesday votes need >50% participation and can choose no victim\n'
                  '• Within 4 weeks, at least one person must be executed on a Wednesday',
            ),
            _buildRuleCard(
              theme,
              title: 'Emergency Meeting',
              content: '• Can be called by a player with urgent suspicion\n'
                  '• Requires >50% of living players to agree\n'
                  '• Follows Wednesday voting rules\n'
                  '• Each person can only call one meeting per game\n'
                  '• Only one meeting per day\n'
                  '• Cannot be called on voting days',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleCard(
    ThemeData theme, {
    required String title,
    required String content,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(content),
          ],
        ),
      ),
    );
  }
}
