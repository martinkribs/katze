part of 'notification_bloc.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();
  
  @override
  List<Object> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoadedState extends NotificationState {
  final List<Notification> notifications;

  const NotificationLoadedState(this.notifications);

  @override
  List<Object> get props => [notifications];

  NotificationLoadedState copyWith({
    List<Notification>? notifications,
  }) {
    return NotificationLoadedState(
      notifications ?? this.notifications,
    );
  }
}
