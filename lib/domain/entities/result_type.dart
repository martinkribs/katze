import 'package:equatable/equatable.dart';

enum ResultOutcome {
  playerEliminated,
  playerProtected,
  playerInvestigated,
  gameOver
}

class ResultType extends Equatable {
  final String id;
  final ResultOutcome outcome;
  final String? affectedPlayerId;
  final String? causingPlayerId;
  final DateTime timestamp;
  final Map<String, dynamic> additionalDetails;

  const ResultType({
    required this.id,
    required this.outcome,
    this.affectedPlayerId,
    this.causingPlayerId,
    required this.timestamp,
    this.additionalDetails = const {},
  });

  @override
  List<Object?> get props => [
    id,
    outcome,
    affectedPlayerId,
    causingPlayerId,
    timestamp,
    additionalDetails,
  ];

  ResultType copyWith({
    String? id,
    ResultOutcome? outcome,
    String? affectedPlayerId,
    String? causingPlayerId,
    DateTime? timestamp,
    Map<String, dynamic>? additionalDetails,
  }) {
    return ResultType(
      id: id ?? this.id,
      outcome: outcome ?? this.outcome,
      affectedPlayerId: affectedPlayerId ?? this.affectedPlayerId,
      causingPlayerId: causingPlayerId ?? this.causingPlayerId,
      timestamp: timestamp ?? this.timestamp,
      additionalDetails: additionalDetails ?? this.additionalDetails,
    );
  }
}
