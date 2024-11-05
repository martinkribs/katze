import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:katze/presentation/bloc/game/game_bloc.dart';
import 'package:katze/presentation/bloc/theme/theme_bloc.dart';
import 'package:katze/presentation/pages/create_game_page.dart';

class GamesOverviewPage extends StatelessWidget {
  const GamesOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Games'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              context.read<ThemeBloc>().add(ToggleThemeEvent());
            },
          ),
        ],
      ),
      body: BlocBuilder<GameBloc, GameState>(
        builder: (context, state) {
          if (state is GameInitial) {
            return const Center(
              child: Text('No games yet. Create a new game!'),
            );
          }

          if (state is GameCreatedState) {
            return _buildGamesList(context, [state.gameInstance]);
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CreateGamePage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGamesList(BuildContext context, List games) {
    return ListView.builder(
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];
        return ListTile(
          title: Text(game.name ?? 'Unnamed Game'),
          subtitle: Text('Players: ${game.players.length}'),
          trailing: Text(game.status.toString().split('.').last),
          onTap: () {
            // TODO: Navigate to game details page
          },
        );
      },
    );
  }
}
