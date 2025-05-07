import 'package:hive/hive.dart';
import '../models/category.dart';
import '../models/task.dart';

class HiveDatabaseService {
  static final HiveDatabaseService _instance = HiveDatabaseService._internal();
  factory HiveDatabaseService() => _instance;
  HiveDatabaseService._internal();

  late final Box<Category> _categoryBox;
  late final Box<Task> _taskBox;

  Future<void> init() async {
    _categoryBox = await Hive.openBox<Category>('categories');
    _taskBox = await Hive.openBox<Task>('tasks');

    if (_categoryBox.isEmpty) {
      final defaultCategories = Category.getDefaultCategories();
      for (final category in defaultCategories) {
        await _categoryBox.put(category.id, category);
      }
    }
  }

  // ======= Catégories =======

  Future<List<Category>> getCategories() async {
    return _categoryBox.values.toList();
  }

  Future<Category?> getCategory(String id) async {
    return _categoryBox.get(id);
  }

  Future<void> insertCategory(Category category) async {
    await _categoryBox.put(category.id, category);
  }

  Future<void> updateCategory(Category category) async {
    await _categoryBox.put(category.id, category);
  }

  Future<void> deleteCategory(String id) async {
    await _categoryBox.delete(id);
  }

  // ======= Tâches =======

  Future<List<Task>> getTasks() async {
    return _taskBox.values.toList();
  }

  Future<Task?> getTask(String id) async {
    return _taskBox.get(id);
  }

  Future<void> insertTask(Task task) async {
    await _taskBox.put(task.id, task);
  }

  Future<void> updateTask(Task task) async {
    await _taskBox.put(task.id, task);
  }

  Future<void> deleteTask(String id) async {
    await _taskBox.delete(id);
  }

  Future<List<Task>> searchTasks(String query) async {
    return _taskBox.values
        .where(
          (task) =>
              task.title.contains(query) || task.description.contains(query),
        )
        .toList();
  }

  Future<List<Task>> filterTasks({
    String? categoryId,
    TaskPriority? priority,
    bool? isCompleted,
    DateTime? dueDateStart,
    DateTime? dueDateEnd,
  }) async {
    return _taskBox.values.where((task) {
      if (categoryId != null && task.categoryId != categoryId) {
        return false;
      }
      if (priority != null && task.priority != priority) {
        return false;
      }
      if (isCompleted != null && task.isCompleted != isCompleted) {
        return false;
      }
      if (dueDateStart != null && task.dueDate != null) {
        if (task.dueDate!.isBefore(dueDateStart)) {
          return false;
        }
      }
      if (dueDateEnd != null && task.dueDate != null) {
        if (task.dueDate!.isAfter(dueDateEnd)) {
          return false;
        }
      }
      return true;
    }).toList();
  }
}
