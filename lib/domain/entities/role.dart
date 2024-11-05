import 'package:equatable/equatable.dart';
import 'package:katze/domain/entities/action.dart';

enum RoleTeam {
  villagers,
  werewolves,
  neutrals
}

enum RoleType {
  // Villager Roles
  basicVillager,
  seer,
  doctor,
  bodyguard,
  
  // Werewolf Roles
  basicWerewolf,
  alphaWerewolf,
  
  // Neutral Roles
  jester,
  serialKiller
}

class Role extends Equatable {
  final String id;
  final RoleType type;
  final RoleTeam team;
  final String name;
  final String description;
  final List<ActionType> allowedActions;
  final Map<String, dynamic> specialRules;

  const Role({
    required this.id,
    required this.type,
    required this.team,
    required this.name,
    required this.description,
    this.allowedActions = const [],
    this.specialRules = const {},
  });

  @override
  List<Object?> get props => [
    id,
    type,
    team,
    name,
    description,
    allowedActions,
    specialRules,
  ];

  Role copyWith({
    String? id,
    RoleType? type,
    RoleTeam? team,
    String? name,
    String? description,
    List<ActionType>? allowedActions,
    Map<String, dynamic>? specialRules,
  }) {
    return Role(
      id: id ?? this.id,
      type: type ?? this.type,
      team: team ?? this.team,
      name: name ?? this.name,
      description: description ?? this.description,
      allowedActions: allowedActions ?? this.allowedActions,
      specialRules: specialRules ?? this.specialRules,
    );
  }

  // Helper method to create predefined roles
  static Role createDefaultRole(RoleType type) {
    switch (type) {
      case RoleType.basicVillager:
        return const Role(
          id: 'role_basic_villager',
          type: RoleType.basicVillager,
          team: RoleTeam.villagers,
          name: 'Villager',
          description: 'A simple villager trying to survive',
          allowedActions: [ActionType.vote],
        );
      
      case RoleType.seer:
        return const Role(
          id: 'role_seer',
          type: RoleType.seer,
          team: RoleTeam.villagers,
          name: 'Seer',
          description: 'Can investigate one player each night',
          allowedActions: [ActionType.vote, ActionType.investigate],
          specialRules: {
            'nightAbility': 'Can reveal the team of one player per night'
          },
        );
      
      case RoleType.basicWerewolf:
        return const Role(
          id: 'role_basic_werewolf',
          type: RoleType.basicWerewolf,
          team: RoleTeam.werewolves,
          name: 'Werewolf',
          description: 'Tries to eliminate villagers at night',
          allowedActions: [ActionType.vote, ActionType.kill],
        );
      
      default:
        throw UnimplementedError('Role not defined');
    }
  }
}
