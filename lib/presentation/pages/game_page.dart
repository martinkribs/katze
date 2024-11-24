import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:katze/presentation/pages/game_settings_page.dart';
import 'package:katze/presentation/providers/game_provider.dart';
import 'package:katze/presentation/widgets/game_details_card.dart';
import 'package:katze/presentation/widgets/player_list.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/services/deep_link_service.dart';

class GamePage extends StatefulWidget {
  final int gameId;

  const GamePage({
    super.key,
    required this.gameId,
  });

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  Future<void> _loadGameData() async {
    final gameProvider = context.read<GameProvider>();
    await gameProvider.loadGameDetails(widget.gameId.toString());
    
    // After game details are loaded, check if we need to load role action types
    final currentGame = gameProvider.currentGame;
    if (currentGame != null && 
        currentGame['currentUser']?['role'] != null && 
        !currentGame['currentUser']['isGameMaster']) {
      print('Loading role action types for role: ${currentGame['currentUser']['role']}'); // Debug print
      await gameProvider.loadRoleActionTypes(
        currentGame['currentUser']['role']['id'].toString(),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Load game data when the page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGameData();
    });
  }

  Future<void> _confirmLeaveGame(
      BuildContext context, GameProvider gameProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Leave Game'),
          content: const Text('Are you sure you want to leave this game?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Leave',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      try {
        await gameProvider.leaveGame(widget.gameId.toString());
        if (mounted) {
          await gameProvider.loadGames();
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Successfully left the game')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to leave game: $e')),
          );
        }
      }
    }
  }

  Future<void> _confirmDelete(
      BuildContext context, GameProvider gameProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Game'),
          content: const Text(
              'Are you sure you want to delete this game? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      try {
        await gameProvider.deleteGame(widget.gameId.toString());
        if (mounted) {
          await gameProvider.loadGames();
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Game deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete game: $e')),
          );
        }
      }
    }
  }

  Future<void> _shareInvite(
      BuildContext context, GameProvider gameProvider) async {
    if (gameProvider.currentGame == null) return;

    try {
      final inviteLink =
          await gameProvider.createInviteLink(widget.gameId.toString());
      final whatsAppText = await gameProvider.generateWhatsAppShareText(
        widget.gameId.toString(),
        gameProvider.currentGame!['name'] ?? 'Unnamed Game',
      );

      if (mounted) {
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
                      Clipboard.setData(
                        ClipboardData(
                          text: DeepLinkService.generateGameInviteLink(
                              inviteLink['token']),
                        ),
                      );
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate invite link: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, _) {
        final gameData = gameProvider.currentGame;
        final theme = Theme.of(context);

        return Scaffold(
          appBar: AppBar(
            title: Text(gameData?['name'] ?? 'Game Details'),
            actions: [
              if (gameData != null) ...[
                if (gameData['currentUser']['isGameMaster']) ...[
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => GameSettingsPage(
                            gameId: widget.gameId,
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _confirmDelete(context, gameProvider),
                  ),
                ] else if (gameData['status'] == 'pending') ...[
                  IconButton(
                    icon: const Icon(Icons.exit_to_app),
                    onPressed: () => _confirmLeaveGame(context, gameProvider),
                  ),
                ],
              ],
            ],
          ),
          body: gameProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : gameProvider.error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            gameProvider.error!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _loadGameData(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : gameData == null
                      ? const Center(child: Text('No game data available'))
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              GameDetailsCard(gameData: gameData),
                              const SizedBox(height: 16),
                              if (gameData['currentUser']['isGameMaster'] &&
                                  gameData['status'] == 'pending') ...[
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      _shareInvite(context, gameProvider),
                                  icon: const Icon(Icons.share),
                                  label: const Text('Invite Players'),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    await gameProvider.startGame(widget.gameId.toString());
                                    // Reload game data after starting
                                    if (mounted) {
                                      _loadGameData();
                                    }
                                  },
                                  icon: const Icon(Icons.play_arrow),
                                  label: const Text('Start Game'),
                                ),
                              ],
                              const SizedBox(height: 16),
                              PlayerList(
                                players: gameData['players'],
                                currentUser: gameData['currentUser'],
                                gameId: widget.gameId.toString(),
                                gameStatus: gameData['status'],
                                isVotingPhase: gameData['gameDetails']['isVotingPhase'] ?? false,
                                gameDetails: gameData['gameDetails'],
                              ),
                            ],
                          ),
                        ),
        );
      },
    );
  }
}
