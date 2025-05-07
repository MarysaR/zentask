import 'package:flutter/material.dart';
import '../models/task.dart';
import 'task_filter_provider.dart';
import 'task_notification_provider.dart';
import 'task_statistics_provider.dart';
import 'category_provider.dart';
import '../services/hive_database_service.dart';
import 'package:logging/logging.dart';

class TaskProvider extends ChangeNotifier
    with
        TaskFilterProvider,
        TaskNotificationProvider,
        TaskStatisticsProvider,
        CategoryProvider {
  List<Task> _tasks = [];
  bool _isLoading = false;
  final Logger _logger = Logger('TaskProvider');

  final HiveDatabaseService _databaseService = HiveDatabaseService();

  @override
  List<Task> get allTasks => _tasks;

  List<Task> get tasks => filterTasks(_tasks);
  bool get isLoading => _isLoading;

  TaskProvider() {
    initNotifications();
    _loadData();
  }

  Future<void> _loadData() async {
    await loadCategories();
    await _loadTasks();
  }

  Future<void> _loadTasks() async {
    _setLoading(true);
    try {
      _tasks = await _databaseService.getTasks();
      notifyListeners();
    } catch (e) {
      _logger.warning('Erreur lors du chargement des tâches: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    _setLoading(true);
    try {
      await _databaseService.insertTask(task);
      _tasks.add(task);
      scheduleTaskNotification(task);
      notifyListeners();
    } catch (e) {
      _logger.warning('Erreur lors de l\'ajout de la tâche: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateTask(Task task) async {
    _setLoading(true);
    try {
      await _databaseService.updateTask(task);
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
        scheduleTaskNotification(task);
        notifyListeners();
      }
    } catch (e) {
      _logger.warning('Erreur lors de la mise à jour de la tâche: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteTask(String id) async {
    _setLoading(true);
    try {
      await _databaseService.deleteTask(id);
      final task = _tasks.firstWhere((t) => t.id == id);
      _tasks.removeWhere((task) => task.id == id);
      cancelTaskNotification(task);
      notifyListeners();
    } catch (e) {
      _logger.warning('Erreur lors de la suppression de la tâche: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleTaskCompletion(String id) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == id);
    if (taskIndex != -1) {
      final task = _tasks[taskIndex];
      final updatedTask = task.copyWith(
        isCompleted: !task.isCompleted,
        updatedAt: DateTime.now(),
      );

      await updateTask(updatedTask);
    }
  }

  Future<void> addSubTask(String taskId, SubTask subTask) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      final task = _tasks[taskIndex];
      final List<SubTask> updatedSubTasks = List.from(task.subTasks)
        ..add(subTask);

      final updatedTask = task.copyWith(
        subTasks: updatedSubTasks,
        updatedAt: DateTime.now(),
      );

      await updateTask(updatedTask);
    }
  }

  Future<void> updateSubTask(String taskId, SubTask subTask) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      final task = _tasks[taskIndex];
      final subTaskIndex = task.subTasks.indexWhere(
        (st) => st.id == subTask.id,
      );

      if (subTaskIndex != -1) {
        final List<SubTask> updatedSubTasks = List.from(task.subTasks);
        updatedSubTasks[subTaskIndex] = subTask;

        final updatedTask = task.copyWith(
          subTasks: updatedSubTasks,
          updatedAt: DateTime.now(),
        );

        await updateTask(updatedTask);
      }
    }
  }

  Future<void> deleteSubTask(String taskId, String subTaskId) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      final task = _tasks[taskIndex];
      final List<SubTask> updatedSubTasks = List.from(task.subTasks)
        ..removeWhere((st) => st.id == subTaskId);

      final updatedTask = task.copyWith(
        subTasks: updatedSubTasks,
        updatedAt: DateTime.now(),
      );

      await updateTask(updatedTask);
    }
  }
}
