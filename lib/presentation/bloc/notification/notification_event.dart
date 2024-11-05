part of 'notification_bloc.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object> get props => [];
}

class AddNotificationEvent extends NotificationEvent {
  final Notification notification;

  const AddNotificationEvent({required this.notification});

  @override
  List<Object> get props => [notification];
}

class MarkNotificationReadEvent extends NotificationEvent {
  final String notificationId;

  const MarkNotificationReadEvent({required this.notificationId});

  @override
  List<Object> get props => [notificationId];
}

class ClearNotificationsEvent extends NotificationEvent {}
