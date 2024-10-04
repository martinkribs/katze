import 'package:equatable/equatable.dart';
import 'package:katze/domain/entities/role_team.dart';

import 'ability.dart';

class Role extends Equatable {
  final String name;
  final String description;
  final int count;
  final RoleTeam team;
  final String? imageUrl;
  final List<Ability> abilities;

  const Role({
    required this.name,
    required this.description,
    required this.count,
    required this.team,
    this.imageUrl,
    this.abilities = const [],
  });

  @override
  List<Object?> get props => [
        name,
        description,
        count,
        team,
        imageUrl,
        abilities,
      ];
}
