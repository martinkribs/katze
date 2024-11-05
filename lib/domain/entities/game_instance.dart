import 'package:equatable/equatable.dart';
import 'package:katze/domain/entities/player.dart';
import 'package:katze/domain/entities/role.dart';
import 'package:katze/domain/entities/round.dart';

enum GameStatus {
  pending,
  inProgress,
  completed
}

class GameInstance extends Equatable {
  final String id;
  final String name;
  final String gameMasterId;
  final GameStatus status;
  final List<Player> players;
  final List<Role> availableRoles;
  final Round? currentRound;
  final Map<String, dynamic> customRules;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? endedAt;

  const GameInstance({
    required this.id,
    required this.name,
    required this.gameMasterId,
    this.status = GameStatus.pending,
    this.players = const [],
    this.availableRoles = const [],
    this.currentRound,
    this.customRules = const {},
    required this.createdAt,
    this.startedAt,
    this.endedAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    gameMasterId,
    status,
    players,
    availableRoles,
    currentRound,
    customRules,
    createdAt,
    startedAt,
    endedAt,
  ];

  GameInstance copyWith({
    String? id,
    String? name,
    String? gameMasterId,
    GameStatus? status,
    List<Player>? players,
    List<Role>? availableRoles,
    Round? currentRound,
    Map<String, dynamic>? customRules,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? endedAt,
  }) {
    return GameInstance(
      id: id ?? this.id,
      name: name ?? this.name,
      gameMasterId: gameMasterId ?? this.gameMasterId,
      status: status ?? this.status,
      players: players ?? this.players,
      availableRoles: availableRoles ?? this.availableRoles,
      currentRound: currentRound ?? this.currentRound,
      customRules: customRules ?? this.customRules,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
    );
  }
}
