import 'package:dartz/dartz.dart';

import 'package:katze/core/error/failures.dart';
import '../entities/role.dart';

abstract class RoleRepository {
  Future<Either<Failure, Role>> getConcreteRole(String name);

  Future<Either<Failure, Role>> getRandomRole();
}
