import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:katze/core/services/auth_service.dart';
import 'package:katze/core/services/game_service.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class GameState extends ChangeNotifier {
  final AuthService _authService;
  final GameService _gameService;
  final int gameId;

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _gameData;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get gameData => _gameData;

  GameState(this._authService, this._gameService, this.gameId) {
    loadGameDetails();
  }

  Future<void> loadGameDetails() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final gameDetails = await _gameService.getGameDetails(gameId);
      _gameData = gameDetails;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> startGame() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedGame = await _gameService.startGame(gameId);
      _gameData = updatedGame;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void shareInvite(BuildContext context) {
    if (_gameData == null) return;

    final inviteLink = _gameService.generateInviteLink(gameId);
    final whatsAppText = _gameService.generateWhatsAppShareText(
      gameId,
      _gameData!['name'] ?? 'Unnamed Game',
    );

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copy Invite Link'),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: inviteLink));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invite link copied!')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share via WhatsApp'),
                onTap: () {
                  Share.share(whatsAppText);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class GamePage extends StatelessWidget {
  final int gameId;

  const GamePage({
    super.key,
    required this.gameId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameState(
        context.read<AuthService>(),
        context.read<GameService>(),
        gameId,
      ),
      child: const _GameView(),
    );
  }
}

class _GameView extends StatelessWidget {
  const _GameView();

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();

    return Scaffold(
      appBar: AppBar(
        title: Text(gameState.gameData?['name'] ?? 'Game Details'),
        actions: [
          if (gameState.gameData != null &&
              gameState.gameData!['isGameMaster'] == 1)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // TODO: Navigate to game settings
              },
            ),
        ],
      ),
      body: gameState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : gameState.errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        gameState.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: gameState.loadGameDetails,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : gameState.gameData == null
                  ? const Center(child: Text('No game data available'))
                  : SingleChildScrollView(
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
                                    'Game Status: ${gameState.gameData!['gameStatus']}',
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Players: ${gameState.gameData!['players']?.length ?? 0}',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (gameState.gameData!['isGameMaster'] == true &&
                              gameState.gameData!['gameStatus'] ==
                                  'pending') ...[
                            ElevatedButton.icon(
                              onPressed: () => gameState.shareInvite(context),
                              icon: const Icon(Icons.share),
                              label: const Text('Invite Players'),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: gameState.startGame,
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Start Game'),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Players',
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 8),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: gameState
                                            .gameData!['players']?.length ??
                                        0,
                                    itemBuilder: (context, index) {
                                      final player =
                                          gameState.gameData!['players'][index];
                                      return ListTile(
                                        leading: const Icon(Icons.person),
                                        title: Text(player['name'] ?? ''),
                                        trailing: player['isGameMaster'] == 1
                                            ? const Chip(
                                                label: Text('Game Master'),
                                              )
                                            : null,
                                      );
                                    },
                                  ),
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
