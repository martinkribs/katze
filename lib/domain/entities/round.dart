import 'package:equatable/equatable.dart';
import 'package:katze/domain/entities/action.dart';
import 'package:katze/domain/entities/result_type.dart';

enum PhaseType {
  day,
  night
}

class Round extends Equatable {
  final String id;
  final String gameInstanceId;
  final int roundNumber;
  final PhaseType currentPhase;
  final DateTime startTime;
  final DateTime? endTime;
  final List<Action> actions;
  final ResultType? phaseResult;

  const Round({
    required this.id,
    required this.gameInstanceId,
    required this.roundNumber,
    required this.currentPhase,
    required this.startTime,
    this.endTime,
    this.actions = const [],
    this.phaseResult,
  });

  @override
  List<Object?> get props => [
    id,
    gameInstanceId,
    roundNumber,
    currentPhase,
    startTime,
    endTime,
    actions,
    phaseResult,
  ];

  Round copyWith({
    String? id,
    String? gameInstanceId,
    int? roundNumber,
    PhaseType? currentPhase,
    DateTime? startTime,
    DateTime? endTime,
    List<Action>? actions,
    ResultType? phaseResult,
  }) {
    return Round(
      id: id ?? this.id,
      gameInstanceId: gameInstanceId ?? this.gameInstanceId,
      roundNumber: roundNumber ?? this.roundNumber,
      currentPhase: currentPhase ?? this.currentPhase,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      actions: actions ?? this.actions,
      phaseResult: phaseResult ?? this.phaseResult,
    );
  }
}
