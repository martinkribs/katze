import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:katze/domain/entities/game_instance.dart';
import 'package:katze/domain/entities/player.dart';
import 'package:katze/domain/entities/role.dart';

part 'game_event.dart';
part 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc() : super(GameInitial()) {
    on<CreateGameEvent>(_onCreateGame);
    on<JoinGameEvent>(_onJoinGame);
    on<StartGameEvent>(_onStartGame);
    on<AssignRolesEvent>(_onAssignRoles);
    on<EndGameEvent>(_onEndGame);
  }

  void _onCreateGame(CreateGameEvent event, Emitter<GameState> emit) {
    try {
      final newGame = GameInstance(
        id: DateTime.now().toString(), // Temporary ID generation
        name: event.gameName,
        gameMasterId: event.userId,
        createdAt: DateTime.now(),
      );
      emit(GameCreatedState(newGame));
    } catch (e) {
      emit(GameErrorState('Failed to create game: ${e.toString()}'));
    }
  }

  void _onJoinGame(JoinGameEvent event, Emitter<GameState> emit) {
    if (state is GameCreatedState) {
      final currentGame = (state as GameCreatedState).gameInstance;
      
      final newPlayer = Player(
        id: DateTime.now().toString(), // Temporary ID generation
        userId: event.userId,
        gameInstanceId: currentGame.id,
        joinedAt: DateTime.now(),
      );

      final updatedPlayers = List<Player>.from(currentGame.players)..add(newPlayer);
      
      final updatedGame = currentGame.copyWith(
        players: updatedPlayers,
      );

      emit(GameCreatedState(updatedGame));
    } else {
      emit(const GameErrorState('Cannot join game. No active game found.'));
    }
  }

  void _onStartGame(StartGameEvent event, Emitter<GameState> emit) {
    if (state is GameCreatedState) {
      final currentGame = (state as GameCreatedState).gameInstance;
      
      if (currentGame.players.length < 2) {
        emit(const GameErrorState('Not enough players to start the game'));
        return;
      }

      final updatedGame = currentGame.copyWith(
        status: GameStatus.inProgress,
        startedAt: DateTime.now(),
      );

      emit(GameStartedState(updatedGame));
    } else {
      emit(const GameErrorState('Cannot start game. No active game found.'));
    }
  }

  void _onAssignRoles(AssignRolesEvent event, Emitter<GameState> emit) {
    if (state is GameStartedState) {
      final currentGame = (state as GameStartedState).gameInstance;
      
      // Simple role assignment strategy
      final players = currentGame.players;
      final roles = _generateRoles(players.length);

      final updatedPlayers = players.map((player) {
        final role = roles.removeAt(0);
        return player.copyWith(assignedRole: role);
      }).toList();

      final updatedGame = currentGame.copyWith(
        players: updatedPlayers,
        availableRoles: roles,
      );

      emit(RolesAssignedState(updatedGame));
    } else {
      emit(const GameErrorState('Cannot assign roles. Game not in progress.'));
    }
  }

  void _onEndGame(EndGameEvent event, Emitter<GameState> emit) {
    if (state is GameStartedState || state is RolesAssignedState) {
      final currentGame = state is GameStartedState 
        ? (state as GameStartedState).gameInstance
        : (state as RolesAssignedState).gameInstance;

      final endedGame = currentGame.copyWith(
        status: GameStatus.completed,
        endedAt: DateTime.now(),
      );

      emit(GameEndedState(endedGame));
    } else {
      emit(const GameErrorState('Cannot end game. No active game found.'));
    }
  }

  List<Role> _generateRoles(int playerCount) {
    // Simple role distribution strategy
    final roles = <Role>[];
    
    // Determine number of roles based on player count
    final werewolfCount = (playerCount * 0.25).ceil();
    final villagerCount = playerCount - werewolfCount;

    // Add werewolf roles
    for (int i = 0; i < werewolfCount; i++) {
      roles.add(Role.createDefaultRole(RoleType.basicWerewolf));
    }

    // Add villager roles
    for (int i = 0; i < villagerCount; i++) {
      roles.add(Role.createDefaultRole(RoleType.basicVillager));
    }

    // Add a seer if possible
    if (playerCount > 5) {
      roles.add(Role.createDefaultRole(RoleType.seer));
    }

    return roles;
  }
}
