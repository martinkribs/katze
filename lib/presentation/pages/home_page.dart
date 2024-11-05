import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:katze/presentation/bloc/game/game_bloc.dart';
import 'package:katze/presentation/bloc/notification/notification_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cat Game'),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<GameBloc, GameState>(
            listener: (context, state) {
              if (state is GameCreatedState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Game created: ${state.gameInstance.name}')),
                );
              }
              if (state is GameErrorState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${state.errorMessage}')),
                );
              }
            },
          ),
          BlocListener<NotificationBloc, NotificationState>(
            listener: (context, state) {
              if (state is NotificationLoadedState) {
                // Handle notifications if needed
              }
            },
          ),
        ],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Trigger game creation event
                  context.read<GameBloc>().add(
                    CreateGameEvent(
                      gameName: 'New Cat Game ${DateTime.now().millisecondsSinceEpoch}',
                      userId: 'current_user_id', // Replace with actual user ID
                    ),
                  );
                },
                child: const Text('Create Game'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Trigger game joining event
                  context.read<GameBloc>().add(
                    const JoinGameEvent(
                      userId: 'current_user_id', // Replace with actual user ID
                      gameId: 'game_id', // Replace with actual game ID
                    ),
                  );
                },
                child: const Text('Join Game'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
