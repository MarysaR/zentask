import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'task.g.dart'; // Requis pour Hive

@HiveType(typeId: 1)
enum TaskPriority {
  @HiveField(0)
  high,

  @HiveField(1)
  medium,

  @HiveField(2)
  low,
}

@HiveType(typeId: 2)
class SubTask extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  bool isCompleted;

  SubTask({String? id, required this.title, this.isCompleted = false})
    : id = id ?? const Uuid().v4();
}

@HiveType(typeId: 3)
class Task extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  bool isCompleted;

  @HiveField(4)
  DateTime? dueDate;

  @HiveField(5)
  String categoryId;

  @HiveField(6)
  TaskPriority priority;

  @HiveField(7)
  List<SubTask> subTasks;

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  DateTime updatedAt;

  Task({
    String? id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.dueDate,
    required this.categoryId,
    this.priority = TaskPriority.medium,
    List<SubTask>? subTasks,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       subTasks = subTasks ?? [],
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Task copyWith({
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? dueDate,
    String? categoryId,
    TaskPriority? priority,
    List<SubTask>? subTasks,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      categoryId: categoryId ?? this.categoryId,
      priority: priority ?? this.priority,
      subTasks: subTasks ?? this.subTasks,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
