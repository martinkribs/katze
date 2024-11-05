import 'package:katze/domain/entities/role.dart';

class GetConcreteRole {
  Role call(RoleType roleType) {
    return Role.createDefaultRole(roleType);
  }
}
