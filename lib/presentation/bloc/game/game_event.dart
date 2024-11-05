part of 'game_bloc.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object> get props => [];
}

class CreateGameEvent extends GameEvent {
  final String gameName;
  final String userId;

  const CreateGameEvent({
    required this.gameName,
    required this.userId,
  });

  @override
  List<Object> get props => [gameName, userId];
}

class JoinGameEvent extends GameEvent {
  final String userId;
  final String gameId;

  const JoinGameEvent({
    required this.userId,
    required this.gameId,
  });

  @override
  List<Object> get props => [userId, gameId];
}

class StartGameEvent extends GameEvent {
  final String gameId;

  const StartGameEvent({
    required this.gameId,
  });

  @override
  List<Object> get props => [gameId];
}

class AssignRolesEvent extends GameEvent {
  final String gameId;

  const AssignRolesEvent({
    required this.gameId,
  });

  @override
  List<Object> get props => [gameId];
}

class EndGameEvent extends GameEvent {
  final String gameId;

  const EndGameEvent({
    required this.gameId,
  });

  @override
  List<Object> get props => [gameId];
}
