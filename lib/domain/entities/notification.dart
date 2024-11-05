import 'package:equatable/equatable.dart';

enum NotificationType {
  gameInvite,
  gameStart,
  roleAssigned,
  playerAction,
  roundUpdate,
  gameOver
}

class Notification extends Equatable {
  final String id;
  final String userId;
  final String? gameInstanceId;
  final NotificationType type;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic> additionalData;

  const Notification({
    required this.id,
    required this.userId,
    this.gameInstanceId,
    required this.type,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.additionalData = const {},
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    gameInstanceId,
    type,
    message,
    timestamp,
    isRead,
    additionalData,
  ];

  Notification copyWith({
    String? id,
    String? userId,
    String? gameInstanceId,
    NotificationType? type,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? additionalData,
  }) {
    return Notification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      gameInstanceId: gameInstanceId ?? this.gameInstanceId,
      type: type ?? this.type,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      additionalData: additionalData ?? this.additionalData,
    );
  }
}
