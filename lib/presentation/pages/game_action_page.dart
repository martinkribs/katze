import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class GameActionPage extends StatelessWidget {
  final String gameId;
  final Map<String, dynamic> targetPlayer;
  final List<dynamic> availableActions;

  const GameActionPage({
    super.key,
    required this.gameId,
    required this.targetPlayer,
    required this.availableActions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Action on ${targetPlayer['name']}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Target Player',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(targetPlayer['name']),
                      subtitle: targetPlayer['role']?['name'] != null && 
                               targetPlayer['role']?['name'] != 'Hidden'
                          ? Text('Role: ${targetPlayer['role']['name']}')
                          : null,
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: targetPlayer['status']['user'] == 'alive' 
                            ? Colors.green 
                            : Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          targetPlayer['status']['user'].toUpperCase(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
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
                    ...availableActions.map((action) => Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(action['name']),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Are you sure you want to ${action['name'].toLowerCase()} ${targetPlayer['name']}?'),
                                    const SizedBox(height: 8),
                                    Text(
                                      action['description'],
                                      style: theme.textTheme.bodySmall,
                                    ),
                                    if (action['usageLimit'] != null) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        'Can be used ${action['usageLimit']} time(s)',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: Text(action['name']),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirmed == true && context.mounted) {
                            try {
                              await context.read<GameProvider>().performAction(
                                gameId: gameId,
                                targetId: targetPlayer['id'].toString(),
                                actionType: action['id'].toString(),
                              );
                              
                              if (context.mounted) {
                                Navigator.of(context).pop(); // Return to game page
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${action['name']} action performed successfully'),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to perform action: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              action['name'],
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              action['description'],
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onPrimary.withOpacity(0.8),
                              ),
                            ),
                            if (action['usageLimit'] != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Can be used ${action['usageLimit']} time(s)',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onPrimary.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    )).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
