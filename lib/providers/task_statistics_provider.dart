import '../models/task.dart';
import '../models/category.dart';

mixin TaskStatisticsProvider {
  List<Task> get allTasks;
  List<Category> get categories;

  Map<String, dynamic> getTaskStatistics() {
    final totalTasks = allTasks.length;
    final completedTasks = allTasks.where((task) => task.isCompleted).length;
    final pendingTasks = totalTasks - completedTasks;

    final tasksByCategory = <String, int>{};
    for (var category in categories) {
      tasksByCategory[category.name] =
          allTasks.where((task) => task.categoryId == category.id).length;
    }

    final tasksByPriority = {
      'high':
          allTasks.where((task) => task.priority == TaskPriority.high).length,
      'medium':
          allTasks.where((task) => task.priority == TaskPriority.medium).length,
      'low': allTasks.where((task) => task.priority == TaskPriority.low).length,
    };

    final upcomingTasks =
        allTasks
            .where(
              (task) =>
                  task.dueDate != null &&
                  task.dueDate!.isAfter(DateTime.now()) &&
                  !task.isCompleted,
            )
            .length;

    final overdueTasks =
        allTasks
            .where(
              (task) =>
                  task.dueDate != null &&
                  task.dueDate!.isBefore(DateTime.now()) &&
                  !task.isCompleted,
            )
            .length;

    return {
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'pendingTasks': pendingTasks,
      'tasksByCategory': tasksByCategory,
      'tasksByPriority': tasksByPriority,
      'upcomingTasks': upcomingTasks,
      'overdueTasks': overdueTasks,
      'completionRate':
          totalTasks > 0
              ? (completedTasks / totalTasks * 100).toStringAsFixed(1)
              : '0',
    };
  }
}
