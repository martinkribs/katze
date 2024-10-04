import 'package:equatable/equatable.dart';

class RoleTeam extends Equatable {
  final String name;
  final String description;
  final String? imageUrl; // Optional: URL zu einem Bild für das Team

  const RoleTeam({
    required this.name,
    required this.description,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [name, description, imageUrl];
}
