import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:katze/domain/entities/notification.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc() : super(NotificationInitial()) {
    on<AddNotificationEvent>(_onAddNotification);
    on<MarkNotificationReadEvent>(_onMarkNotificationRead);
    on<ClearNotificationsEvent>(_onClearNotifications);
  }

  void _onAddNotification(AddNotificationEvent event, Emitter<NotificationState> emit) {
    if (state is NotificationLoadedState) {
      final currentState = state as NotificationLoadedState;
      final updatedNotifications = List<Notification>.from(currentState.notifications)
        ..add(event.notification);
      
      emit(NotificationLoadedState(updatedNotifications));
    } else {
      emit(NotificationLoadedState([event.notification]));
    }
  }

  void _onMarkNotificationRead(MarkNotificationReadEvent event, Emitter<NotificationState> emit) {
    if (state is NotificationLoadedState) {
      final currentState = state as NotificationLoadedState;
      final updatedNotifications = currentState.notifications.map((notification) {
        return notification.id == event.notificationId
          ? notification.copyWith(isRead: true)
          : notification;
      }).toList();
      
      emit(NotificationLoadedState(updatedNotifications));
    }
  }

  void _onClearNotifications(ClearNotificationsEvent event, Emitter<NotificationState> emit) {
    emit(NotificationInitial());
  }
}
