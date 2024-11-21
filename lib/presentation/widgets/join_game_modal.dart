import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:katze/presentation/providers/game_provider.dart';

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
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _gameData;

  @override
  void initState() {
    super.initState();
    _joinGame();
  }

  Future<void> _joinGame() async {
    try {
      final gameProvider = Provider.of<GameProvider>(context, listen: false);
      await gameProvider.joinGame(widget.token);
      
      if (mounted) {
        setState(() {
          _gameData = gameProvider.currentGame;
          _isLoading = false;
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
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isLoading) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Joining game...'),
            ] else if (_error != null) ...[
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
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
  }
}
