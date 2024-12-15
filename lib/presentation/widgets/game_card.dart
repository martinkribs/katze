import 'package:flutter/material.dart';
import 'package:katze/presentation/widgets/game_status_dot.dart';

class GameCard extends StatelessWidget {
  final Map<String, dynamic> game;
  final VoidCallback onTap;

  const GameCard({
    super.key,
    required this.game,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      game['name'] ?? 'Unnamed Game',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  GameStatusDot(status: game['status']),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.people, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${game['playerCount'] ?? 0} Players',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
