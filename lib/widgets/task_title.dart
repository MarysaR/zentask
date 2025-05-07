import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../models/category.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';
import '../config/theme.dart';
import '../utils/date_formatter.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onToggleCompletion;

  const TaskTile({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggleCompletion,
  });

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    final category = taskProvider.categories.firstWhere(
      (c) => c.id == task.categoryId,
      orElse: () => Category(name: 'Autre'),
    );

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color:
              task.isCompleted
                  ? Colors.grey.shade300
                  : _getPriorityColor(task.priority, isDarkMode),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Checkbox(
                value: task.isCompleted,
                onChanged: (_) => onToggleCompletion(),
                activeColor:
                    isDarkMode ? AppTheme.lilacDark : AppTheme.lilacLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Pastille de catégorie améliorée pour le mode sombre
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isDarkMode
                                    ? category.color.withAlpha(100)
                                    : category.color.withAlpha(20),
                            borderRadius: BorderRadius.circular(12),
                            border:
                                isDarkMode
                                    ? Border.all(
                                      color: Colors.white70,
                                      width: 0.8,
                                    )
                                    : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                category.icon,
                                size: 12,
                                color:
                                    isDarkMode ? Colors.white : category.color,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                category.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      isDarkMode
                                          ? Colors.white
                                          : category.color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Badge de priorité amélioré pour le mode sombre
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isDarkMode
                                    ? _getPriorityColor(
                                      task.priority,
                                      isDarkMode,
                                    ).withAlpha(100)
                                    : _getPriorityColor(
                                      task.priority,
                                      isDarkMode,
                                    ).withAlpha(20),
                            borderRadius: BorderRadius.circular(12),
                            border:
                                isDarkMode
                                    ? Border.all(
                                      color: Colors.white70,
                                      width: 0.8,
                                    )
                                    : null,
                          ),
                          child: Text(
                            _getPriorityText(task.priority),
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  isDarkMode
                                      ? Colors.white
                                      : _getPriorityColor(
                                        task.priority,
                                        isDarkMode,
                                      ),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Titre de la tâche
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration:
                            task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                        color:
                            task.isCompleted
                                ? (isDarkMode ? Colors.grey[400] : Colors.grey)
                                : (isDarkMode
                                    ? const Color.fromARGB(255, 77, 73, 73)
                                    : Colors.black87),
                      ),
                    ),

                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              task.isCompleted
                                  ? (isDarkMode
                                      ? Colors.grey[400]
                                      : Colors.grey)
                                  : (isDarkMode
                                      ? const Color.fromARGB(179, 68, 65, 65)
                                      : Colors.black54),
                          decoration:
                              task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),

                    if (task.dueDate != null)
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color:
                                _isOverdue(task.dueDate!)
                                    ? Colors.red
                                    : (isDarkMode
                                        ? Colors.white70
                                        : Colors.grey),
                          ),
                          const SizedBox(width: 4),

                          Text(
                            DateFormatter.formatRelativeDate(task.dueDate!),
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  _isOverdue(task.dueDate!)
                                      ? Colors.red
                                      : (isDarkMode
                                          ? const Color.fromARGB(179, 5, 5, 5)
                                          : Colors.grey),
                              fontWeight:
                                  _isOverdue(task.dueDate!)
                                      ? FontWeight.bold
                                      : null,
                            ),
                          ),

                          if (!DateFormatter.isOverdue(task.dueDate!) &&
                              !task.isCompleted) ...[
                            const SizedBox(width: 8),
                            Text(
                              DateFormatter.formatTimeRemaining(task.dueDate!),
                              style: TextStyle(
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                                color:
                                    isDarkMode
                                        ? const Color.fromARGB(179, 5, 5, 5)
                                        : Color.fromARGB(255, 104, 100, 100),
                              ),
                            ),
                          ],
                        ],
                      ),

                    if (task.subTasks.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.format_list_bulleted,
                            size: 14,
                            color:
                                isDarkMode
                                    ? const Color.fromARGB(179, 5, 5, 5)
                                    : Color.fromARGB(255, 104, 100, 100),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${task.subTasks.where((st) => st.isCompleted).length}/${task.subTasks.length} sous-tâches',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  isDarkMode
                                      ? const Color.fromARGB(179, 5, 5, 5)
                                      : Color.fromARGB(255, 104, 100, 100),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority, bool isDarkMode) {
    switch (priority) {
      case TaskPriority.high:
        return isDarkMode ? Colors.red[300]! : Colors.red;
      case TaskPriority.medium:
        return isDarkMode ? Colors.orange[300]! : Colors.orange;
      case TaskPriority.low:
        return isDarkMode ? Colors.green[300]! : Colors.green;
    }
  }

  String _getPriorityText(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return 'Haute';
      case TaskPriority.medium:
        return 'Moyenne';
      case TaskPriority.low:
        return 'Basse';
    }
  }

  bool _isOverdue(DateTime dueDate) {
    final now = DateTime.now();
    return dueDate.isBefore(now) && !DateUtils.isSameDay(dueDate, now);
  }
}
