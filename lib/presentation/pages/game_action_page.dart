import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:katze/presentation/providers/loading_provider.dart';
import 'package:katze/presentation/providers/game_action_provider.dart';
import 'package:katze/presentation/widgets/player_info_card.dart';
import 'package:katze/presentation/widgets/game_action_list.dart';

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
    return Consumer2<LoadingProvider, GameActionProvider>(
      builder: (context, loadingProvider, gameActionProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Action on ${targetPlayer['name']}'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PlayerInfoCard(
                  player: targetPlayer,
                  title: 'Target Player',
                ),
                const SizedBox(height: 16),
                GameActionList(
                  actions: availableActions,
                  targetPlayer: targetPlayer,
                  gameId: gameId,
                  isLoading: loadingProvider.isLoading,
                  onActionComplete: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
