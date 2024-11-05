import 'package:equatable/equatable.dart';
import 'package:katze/domain/entities/role.dart';

enum PlayerStatus {
  alive,
  dead,
  eliminated
}

class Player extends Equatable {
  final String id;
  final String userId;
  final String gameInstanceId;
  final Role? assignedRole;
  final PlayerStatus status;
  final bool isGameMaster;
  final DateTime joinedAt;
  final List<String> specialAbilities;

  const Player({
    required this.id,
    required this.userId,
    required this.gameInstanceId,
    this.assignedRole,
    this.status = PlayerStatus.alive,
    this.isGameMaster = false,
    required this.joinedAt,
    this.specialAbilities = const [],
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    gameInstanceId,
    assignedRole,
    status,
    isGameMaster,
    joinedAt,
    specialAbilities,
  ];

  Player copyWith({
    String? id,
    String? userId,
    String? gameInstanceId,
    Role? assignedRole,
    PlayerStatus? status,
    bool? isGameMaster,
    DateTime? joinedAt,
    List<String>? specialAbilities,
  }) {
    return Player(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      gameInstanceId: gameInstanceId ?? this.gameInstanceId,
      assignedRole: assignedRole ?? this.assignedRole,
      status: status ?? this.status,
      isGameMaster: isGameMaster ?? this.isGameMaster,
      joinedAt: joinedAt ?? this.joinedAt,
      specialAbilities: specialAbilities ?? this.specialAbilities,
    );
  }
}
