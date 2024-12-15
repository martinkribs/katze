import 'package:flutter/material.dart';

class PlayerInfoCard extends StatelessWidget {
  final Map<String, dynamic> player;
  final String? title;

  const PlayerInfoCard({
    super.key,
    required this.player,
    this.title,
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
            if (title != null) ...[
              Text(
                title!,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
            ],
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(player['name']),
              subtitle: player['role']?['name'] != null && 
                       player['role']?['name'] != 'Hidden'
                  ? Text('Role: ${player['role']['name']}')
                  : null,
              trailing: Container(
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
            ),
          ],
        ),
      ),
    );
  }
}
