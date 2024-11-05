import 'package:equatable/equatable.dart';

enum ActionType {
  vote,
  kill,
  protect,
  investigate,
  heal,
  reveal
}

class Action extends Equatable {
  final String id;
  final String playerId;
  final String targetPlayerId;
  final ActionType type;
  final DateTime timestamp;

  const Action({
    required this.id,
    required this.playerId,
    required this.targetPlayerId,
    required this.type,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
    id,
    playerId,
    targetPlayerId,
    type,
    timestamp,
  ];

  Action copyWith({
    String? id,
    String? playerId,
    String? targetPlayerId,
    ActionType? type,
    DateTime? timestamp,
  }) {
    return Action(
      id: id ?? this.id,
      playerId: playerId ?? this.playerId,
      targetPlayerId: targetPlayerId ?? this.targetPlayerId,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
