import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/task.dart';

class NotificationService {
  // Correction du pattern Singleton
  static final NotificationService _instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> init() async {
    // Initialiser timezone
    tz.initializeTimeZones();

    // Configuration pour Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuration pour iOS
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    // Configuration globale
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Demander les permissions de notification
  Future<void> requestPermissions() async {
    // Pour iOS uniquement
    final iOSPlatform =
        flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();

    if (iOSPlatform != null) {
      await iOSPlatform.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  // Planifier une notification pour une tâche
  Future<void> scheduleTaskNotification(Task task) async {
    // Ne planifier que si la tâche a une date d'échéance
    if (task.dueDate == null) return;

    // Calculer le moment de la notification (1 heure avant l'échéance)
    final scheduledDate = tz.TZDateTime.from(
      task.dueDate!.subtract(const Duration(hours: 1)),
      tz.local,
    );

    // Si la date est déjà passée, déclencher immédiatement une notification
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      await showImmediateNotification(task);
      return;
    }

    // Configuration de la notification pour Android
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        const AndroidNotificationDetails(
          'todo_app_channel',
          'Todo App Notifications',
          channelDescription: 'Notifications for tasks due soon',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          fullScreenIntent: true,
        );

    // Configuration de la notification pour iOS
    DarwinNotificationDetails iOSPlatformChannelSpecifics =
        const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    // Planifier la notification
    await flutterLocalNotificationsPlugin.zonedSchedule(
      task.id.hashCode, // ID unique pour chaque notification
      'Tâche à faire bientôt : ${task.title}',
      task.description.isNotEmpty
          ? task.description
          : 'Cette tâche doit être terminée bientôt.',
      scheduledDate,
      platformChannelSpecifics,
      androidScheduleMode:
          AndroidScheduleMode
              .exactAllowWhileIdle, // Changé pour s'assurer que la notification se déclenche
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Nouvelle méthode pour les notifications immédiates
  Future<void> showImmediateNotification(Task task) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        const AndroidNotificationDetails(
          'todo_app_channel',
          'Todo App Notifications',
          channelDescription: 'Notifications for tasks due soon',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          fullScreenIntent: true,
        );

    DarwinNotificationDetails iOSPlatformChannelSpecifics =
        const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      task.id.hashCode,
      'Tâche en retard : ${task.title}',
      task.description.isNotEmpty
          ? task.description
          : 'Cette tâche devrait déjà être terminée.',
      platformChannelSpecifics,
    );
  }

  // Méthode pour reprogrammer toutes les notifications
  Future<void> rescheduleAllNotifications(List<Task> tasks) async {
    // Annuler toutes les notifications existantes
    await cancelAllNotifications();

    // Reprogrammer les notifications pour toutes les tâches non complétées
    for (final task in tasks) {
      if (!task.isCompleted && task.dueDate != null) {
        await scheduleTaskNotification(task);
      }
    }
  }

  // Annuler une notification pour une tâche
  Future<void> cancelTaskNotification(Task task) async {
    await flutterLocalNotificationsPlugin.cancel(task.id.hashCode);
  }

  // Annuler toutes les notifications
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
