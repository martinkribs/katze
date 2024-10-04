import 'package:equatable/equatable.dart';
import 'package:katze/domain/entities/role.dart';

class Player extends Equatable {
  final String id;
  final String name;
  final Role role;
  final bool isAlive;
  final bool isHost;
  final Player? vote;

  const Player({
    required this.id,
    required this.name,
    required this.role,
    required this.isAlive,
    required this.isHost,
    this.vote,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        role,
        isAlive,
        isHost,
        vote,
      ];
}
