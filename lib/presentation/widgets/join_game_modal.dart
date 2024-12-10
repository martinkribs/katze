import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:katze/presentation/providers/loading_provider.dart';
import 'package:katze/presentation/providers/game_invite_provider.dart';
import 'package:katze/presentation/providers/game_management_provider.dart';

class JoinGameModal extends StatefulWidget {
  final String token;

  const JoinGameModal({
    super.key,
    required this.token,
  });

  @override
  State<JoinGameModal> createState() => _JoinGameModalState();
}

class _JoinGameModalState extends State<JoinGameModal> {
  Map<String, dynamic>? _gameData;

  @override
  void initState() {
    super.initState();
    _joinGame();
  }

  Future<void> _joinGame() async {
    try {
      final gameInviteProvider = Provider.of<GameInviteProvider>(context, listen: false);
      final gameManagementProvider = Provider.of<GameManagementProvider>(context, listen: false);
      await gameInviteProvider.joinGame(widget.token);
      
      if (mounted) {
        setState(() {
          _gameData = gameManagementProvider.currentGame;
        });
        
        // Navigate to game page after successful join
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed(
              '/game',
              arguments: _gameData?['id'],
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        context.read<LoadingProvider>().setError(e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<LoadingProvider, GameManagementProvider>(
      builder: (context, loadingProvider, gameManagementProvider, _) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (loadingProvider.isLoading) ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text('Joining game...'),
                ] else if (loadingProvider.error != null) ...[
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    loadingProvider.error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ] else ...[
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Successfully joined ${_gameData?['name'] ?? 'game'}!',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Redirecting to game...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
