import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:katze/presentation/pages/game_settings_page.dart';
import 'package:katze/presentation/providers/game_provider.dart';
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
  @override
  void initState() {
    super.initState();
    // Load game details when the page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameProvider>().loadGameDetails(widget.gameId.toString());
    });
  }

  Future<void> _confirmLeaveGame(BuildContext context, GameProvider gameProvider) async {
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
          // Refresh games list and navigate back
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

  Future<void> _confirmDelete(BuildContext context, GameProvider gameProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Game'),
          content: const Text('Are you sure you want to delete this game? This action cannot be undone.'),
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
          // Refresh games list before navigating back
          await gameProvider.loadGames();
          Navigator.of(context).pop(); // Return to games list
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

  Widget _buildGameDetails(Map<String, dynamic> gameData, ThemeData theme) {
    final gameDetails = gameData['gameDetails'];
    final currentUserRole = gameData['currentUserRole'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Game Status: ${gameData['status']}',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Players: ${gameData['playerCount']} / ${gameData['minPlayers']}',
              style: theme.textTheme.titleMedium,
            ),
            if (gameDetails['startedAt'] != null) ...[
              const SizedBox(height: 8),
              Text('Started: ${gameDetails['startedAt']}'),
            ],
            if (gameDetails['completedAt'] != null) ...[
              const SizedBox(height: 8),
              Text('Completed: ${gameDetails['completedAt']}'),
              if (gameDetails['winningTeam'] != null)
                Text('Winning Team: ${gameDetails['winningTeam']}'),
            ],
            const SizedBox(height: 8),
            Text('Time Zone: ${gameDetails['timezone']}'),
            if (currentUserRole['isGameMaster'])
              Text('Role: Game Master',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(color: theme.primaryColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayersList(List<dynamic> players, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Players',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: players.length,
              itemBuilder: (context, index) {
                final player = players[index];
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(player['name'] ?? ''),
                  subtitle: player['role'] != null
                      ? Text('Role: ${player['role']['name']}')
                      : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (player['isGameMaster'])
                        const Chip(label: Text('Game Master')),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
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
                if (gameData['currentUserRole']['isGameMaster']) ...[
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
                ] else ...[
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
                            onPressed: () => gameProvider
                                .loadGameDetails(widget.gameId.toString()),
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
                              _buildGameDetails(gameData, theme),
                              const SizedBox(height: 16),
                              if (gameData['currentUserRole']['isGameMaster'] &&
                                  gameData['status'] == 'pending') ...[
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      _shareInvite(context, gameProvider),
                                  icon: const Icon(Icons.share),
                                  label: const Text('Invite Players'),
                                ),
                                const SizedBox(height: 8),
                                if (gameData['playerCount'] >=
                                    gameData['minPlayers'])
                                  ElevatedButton.icon(
                                    onPressed: () => gameProvider
                                        .startGame(widget.gameId.toString()),
                                    icon: const Icon(Icons.play_arrow),
                                    label: const Text('Start Game'),
                                  )
                                else
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Need at least ${gameData['minPlayers']} players to start',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(color: Colors.red),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                              ],
                              const SizedBox(height: 16),
                              _buildPlayersList(gameData['players'], theme),
                            ],
                          ),
                        ),
        );
      },
    );
  }
}
