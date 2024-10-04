import 'package:equatable/equatable.dart';
import 'package:katze/domain/entities/player.dart';
import 'package:katze/domain/entities/role.dart';

class Game extends Equatable {
  final String id;
  final String? name;
  final String status;
  final List<Player> players;
  final List<Role> roles;
  final int day;
  final DateTime? time;
  final Map<String, dynamic> settings;

  const Game({
    required this.id,
    this.name,
    required this.status,
    required this.players,
    required this.roles,
    required this.day,
    this.time,
    this.settings = const {},
  });

  @override
  List<Object?> get props => [
        id,
        name,
        status,
        players,
        roles,
        day,
        time,
        settings,
      ];
}
