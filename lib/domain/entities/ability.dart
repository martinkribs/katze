import 'package:equatable/equatable.dart';

class Ability extends Equatable {
  final String name;
  final String description;
  final String? imageUrl;

  const Ability({
    required this.name,
    required this.description,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [name, description, imageUrl];
}
