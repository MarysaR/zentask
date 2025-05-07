import '../models/task.dart';
import '../services/notification_service.dart';

mixin TaskNotificationProvider {
  final NotificationService _notificationService = NotificationService();

  List<Task> get allTasks;

  // Initialiser les notifications
  Future<void> initNotifications() async {
    await _notificationService.init();
    await _notificationService.requestPermissions();
    await rescheduleAllNotifications();
  }

  // Planifier une notification pour une tâche
  Future<void> scheduleTaskNotification(Task task) async {
    if (task.dueDate != null && !task.isCompleted) {
      await _notificationService.scheduleTaskNotification(task);
    } else {
      await _notificationService.cancelTaskNotification(task);
    }
  }

  // Annuler une notification pour une tâche
  Future<void> cancelTaskNotification(Task task) async {
    await _notificationService.cancelTaskNotification(task);
  }

  // Reprogrammer toutes les notifications
  Future<void> rescheduleAllNotifications() async {
    final tasksToNotify =
        allTasks
            .where((task) => !task.isCompleted && task.dueDate != null)
            .toList();

    // Service pour reprogrammer toutes les notifications
    await _notificationService.rescheduleAllNotifications(tasksToNotify);
  }
}
