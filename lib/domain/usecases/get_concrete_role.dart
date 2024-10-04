import '../../core/error/failures.dart';
import '../entities/role.dart';
import '../repositories/role_repository.dart';
import 'package:dartz/dartz.dart';

class GetConcreteRole {
  final RoleRepository repository;

  GetConcreteRole(this.repository);

  Future<Either<Failure, Role>> execute({
    required String name,
  }) async {
    return await repository.getConcreteRole(name);
  }
}
