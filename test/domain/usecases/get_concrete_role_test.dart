import 'package:flutter_test/flutter_test.dart';
import 'package:katze/domain/entities/role.dart';
import 'package:katze/domain/usecases/get_concrete_role.dart';

void main() {
  late GetConcreteRole getConcreteRole;

  setUp(() {
    getConcreteRole = GetConcreteRole();
  });

  test('should return a concrete role', () {
    // Arrange & Act
    final Role villagerRole = getConcreteRole(RoleType.basicVillager);

    // Assert
    expect(villagerRole.type, RoleType.basicVillager);
    expect(villagerRole.team, RoleTeam.villagers);
    expect(villagerRole.name, 'Villager');
  });

  test('should return different roles', () {
    // Arrange
    final Role villagerRole = getConcreteRole(RoleType.basicVillager);
    final Role seerRole = getConcreteRole(RoleType.seer);

    // Assert
    expect(villagerRole.type, RoleType.basicVillager);
    expect(seerRole.type, RoleType.seer);
    expect(villagerRole != seerRole, true);
  });
}
