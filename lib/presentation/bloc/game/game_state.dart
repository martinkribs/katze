part of 'game_bloc.dart';

abstract class GameState extends Equatable {
  const GameState();
  
  @override
  List<Object> get props => [];
}

class GameInitial extends GameState {}

class GameCreatedState extends GameState {
  final GameInstance gameInstance;

  const GameCreatedState(this.gameInstance);

  @override
  List<Object> get props => [gameInstance];
}

class GameStartedState extends GameState {
  final GameInstance gameInstance;

  const GameStartedState(this.gameInstance);

  @override
  List<Object> get props => [gameInstance];
}

class RolesAssignedState extends GameState {
  final GameInstance gameInstance;

  const RolesAssignedState(this.gameInstance);

  @override
  List<Object> get props => [gameInstance];
}

class GameEndedState extends GameState {
  final GameInstance gameInstance;

  const GameEndedState(this.gameInstance);

  @override
  List<Object> get props => [gameInstance];
}

class GameErrorState extends GameState {
  final String errorMessage;

  const GameErrorState(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
