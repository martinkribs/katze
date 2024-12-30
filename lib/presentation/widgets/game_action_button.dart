import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:katze/presentation/providers/game_action_provider.dart';

class GameActionButton extends StatelessWidget {
  final Map<String, dynamic> action;
  final Map<String, dynamic> targetPlayer;
  final String gameId;
  final bool isLoading;
  final VoidCallback? onActionComplete;

  const GameActionButton({
    super.key,
    required this.action,
    required this.targetPlayer,
    required this.gameId,
    required this.isLoading,
    this.onActionComplete,
  });

  Future<void> _showConfirmationDialog(BuildContext context) async {
    final theme = Theme.of(context);
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
              if (action['usage_limit'] != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Used ${action['actions_used']}/${action['usage_limit']} time(s)',
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
        final gameActionProvider = context.read<GameActionProvider>();
        await gameActionProvider.performAction(
          gameId: gameId,
          targetId: targetPlayer['id'].toString(),
          actionType: action['id'].toString(),
        );
        
        if (context.mounted) {
          onActionComplete?.call();
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final usageLimit = action['usage_limit'];
    final actionsUsed = action['actions_used'];
    final canUse = action['can_use'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: !canUse ? theme.disabledColor : null,
        ),
        onPressed: (isLoading || !canUse) ? null : () => _showConfirmationDialog(context),
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
            if (usageLimit != null) ...[
              const SizedBox(height: 8),
              Text(
                'Used $actionsUsed/${usageLimit} time(s)',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimary.withOpacity(0.7),
                  fontWeight: !canUse ? FontWeight.bold : null,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
