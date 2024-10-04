import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:katze/domain/entities/role.dart';
import 'package:katze/domain/entities/role_team.dart';
import 'package:katze/domain/repositories/role_repository.dart';
import 'package:katze/domain/usecases/get_concrete_role.dart';
import 'package:mockito/mockito.dart';

class MockRoleRepository extends Mock implements RoleRepository {}

void main() {
  late GetConcreteRole usecase;
  late MockRoleRepository mockRoleRepository;

  setUp(() {
    mockRoleRepository = MockRoleRepository();
    usecase = GetConcreteRole(mockRoleRepository);
  });

  const tName = 'Test Role';
  const tRole = Role(
    name: 'Test Role',
    description: 'Test Description',
    count: 1,
    team: RoleTeam(name: 'Test Team', description: 'Test Description'),
    abilities: [],
  );

  test(
    'Should return the role for the given name from the repository',
    () async {
      // Simulate adding the role to the repository
      when(mockRoleRepository.getConcreteRole(tName))
          .thenAnswer((_) async => Future.value(const Right(tRole)));

      // Execute the use case with the name tName
      final result = await usecase.execute(name: tName);

      // Verify the result: result should be Right(tRole)
      expect(result, const Right(tRole));

      // Verify that getConcreteRole was called on the repository with tName
      verify(mockRoleRepository.getConcreteRole(tName));

      // Verify that no other methods were called on the repository
      verifyNoMoreInteractions(mockRoleRepository);
    },
  );
}
