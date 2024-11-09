import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:katze/core/services/game_service.dart';
import 'package:katze/di/injection_container.dart';
import 'package:share_plus/share_plus.dart';

class GamePage extends StatefulWidget {
  final dynamic gameId;

  const GamePage({
    super.key,
    required this.gameId,
  });

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final _gameService = sl<GameService>();
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _gameData;

  @override
  void initState() {
    super.initState();
    _loadGameDetails();
  }

  Future<void> _loadGameDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Convert gameId to string to ensure compatibility
      final gameId = widget.gameId.toString();
      final gameDetails = await _gameService.getGameDetails(gameId);
      setState(() {
        _gameData = gameDetails;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _startGame() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final gameId = widget.gameId.toString();
      final updatedGame = await _gameService.startGame(gameId);
      setState(() {
        _gameData = updatedGame;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _shareInvite() {
    if (_gameData == null) return;

    final gameId = widget.gameId.toString();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_gameData?['name'] ?? 'Game Details'),
        actions: [
          if (_gameData != null && _gameData!['isGameMaster'] == true)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // TODO: Navigate to game settings
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadGameDetails,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _gameData == null
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
                                    'Game Status: ${_gameData!['status']}',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Players: ${_gameData!['players']?.length ?? 0}',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_gameData!['isGameMaster'] == true &&
                              _gameData!['status'] == 'pending') ...[
                            ElevatedButton.icon(
                              onPressed: _shareInvite,
                              icon: const Icon(Icons.share),
                              label: const Text('Invite Players'),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: _startGame,
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
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 8),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount:
                                        _gameData!['players']?.length ?? 0,
                                    itemBuilder: (context, index) {
                                      final player = _gameData!['players'][index];
                                      return ListTile(
                                        leading: const Icon(Icons.person),
                                        title: Text(player['name'] ?? ''),
                                        trailing: player['isGameMaster'] == true
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
