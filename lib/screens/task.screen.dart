import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';
import '../config/theme.dart';

class TaskScreen extends StatefulWidget {
  final Task? task;

  const TaskScreen({super.key, this.task});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _selectedCategoryId;
  late TaskPriority _selectedPriority;
  late DateTime? _selectedDate;
  late TimeOfDay? _selectedTime;
  late List<SubTask> _subTasks;
  late bool _isCompleted;

  final TextEditingController _subTaskController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.task?.description ?? '',
    );
    _selectedPriority = widget.task?.priority ?? TaskPriority.medium;
    _isCompleted = widget.task?.isCompleted ?? false;

    if (widget.task?.dueDate != null) {
      _selectedDate = widget.task!.dueDate;
      _selectedTime = TimeOfDay.fromDateTime(widget.task!.dueDate!);
    } else {
      _selectedDate = null;
      _selectedTime = null;
    }

    _subTasks = widget.task?.subTasks.toList() ?? [];

    _selectedCategoryId = '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subTaskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final categories = taskProvider.categories;

    // Initialiser la catégorie si nécessaire
    if (_selectedCategoryId.isEmpty && categories.isNotEmpty) {
      _selectedCategoryId = widget.task?.categoryId ?? categories.first.id;
    }

    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return Scaffold(
      backgroundColor:
          isDarkMode
              ? AppTheme.darkBackgroundColor
              : AppTheme.lightBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.task == null ? 'Nouvelle tâche' : 'Modifier la tâche',
        ),
        actions: [
          if (widget.task != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteConfirmation(context),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Titre
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Titre',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un titre';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description (optionnelle)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Catégorie
            DropdownButtonFormField<String>(
              value: _selectedCategoryId,
              decoration: InputDecoration(
                labelText: 'Catégorie',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items:
                  categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category.id,
                      child: Row(
                        children: [
                          Icon(category.icon, color: category.color, size: 20),
                          const SizedBox(width: 8),
                          Text(category.name),
                        ],
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategoryId = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Priorité
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Priorité',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                SegmentedButton<TaskPriority>(
                  segments: const [
                    ButtonSegment<TaskPriority>(
                      value: TaskPriority.low,
                      label: Text('Basse'),
                      icon: Icon(Icons.arrow_downward),
                    ),
                    ButtonSegment<TaskPriority>(
                      value: TaskPriority.medium,
                      label: Text('Moyenne'),
                      icon: Icon(Icons.remove),
                    ),
                    ButtonSegment<TaskPriority>(
                      value: TaskPriority.high,
                      label: Text('Haute'),
                      icon: Icon(Icons.arrow_upward),
                    ),
                  ],
                  selected: {_selectedPriority},
                  onSelectionChanged: (Set<TaskPriority> newSelection) {
                    setState(() {
                      _selectedPriority = newSelection.first;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Date et heure d'échéance
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Date d\'échéance',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedDate != null
                                ? DateFormat(
                                  'dd/MM/yyyy',
                                ).format(_selectedDate!)
                                : 'Aucune',
                          ),
                          const Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap:
                        _selectedDate != null
                            ? () => _selectTime(context)
                            : null,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Heure',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabled: _selectedDate != null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedTime != null
                                ? _selectedTime!.format(context)
                                : 'Aucune',
                          ),
                          const Icon(Icons.access_time),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Statut de complétion
            SwitchListTile(
              title: const Text('Tâche terminée'),
              value: _isCompleted,
              onChanged: (value) {
                setState(() {
                  _isCompleted = value;
                });
              },
              activeColor: AppTheme.lilacLight,
            ),
            const SizedBox(height: 16),

            const Text(
              'Sous-tâches',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _subTaskController,
                    decoration: InputDecoration(
                      hintText: 'Ajouter une sous-tâche',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addSubTask,
                  color: AppTheme.lilacLight,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Liste des sous-tâches
            ..._subTasks.asMap().entries.map((entry) {
              final index = entry.key;
              final subTask = entry.value;
              return ListTile(
                leading: Checkbox(
                  value: subTask.isCompleted,
                  onChanged: (value) {
                    setState(() {
                      _subTasks[index] = SubTask(
                        id: subTask.id,
                        title: subTask.title,
                        isCompleted: value!,
                      );
                    });
                  },
                  activeColor: AppTheme.lilacLight,
                ),
                title: Text(
                  subTask.title,
                  style: TextStyle(
                    decoration:
                        subTask.isCompleted ? TextDecoration.lineThrough : null,
                    color: subTask.isCompleted ? Colors.grey : Colors.black87,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _subTasks.removeAt(index);
                    });
                  },
                ),
              );
            }),

            // Bouton d'enregistrement
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveTask,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lilacLight,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                widget.task == null
                    ? 'Créer la tâche'
                    : 'Enregistrer les modifications',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppTheme.lilacLight),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedTime ??= TimeOfDay.now();
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppTheme.lilacLight),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _addSubTask() {
    if (_subTaskController.text.isEmpty) return;

    setState(() {
      _subTasks.add(
        SubTask(title: _subTaskController.text, isCompleted: false),
      );
      _subTaskController.clear();
    });
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) return;

    DateTime? dueDate;
    if (_selectedDate != null && _selectedTime != null) {
      dueDate = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
    }

    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    if (widget.task == null) {
      final newTask = Task(
        title: _titleController.text,
        description: _descriptionController.text,
        categoryId: _selectedCategoryId,
        priority: _selectedPriority,
        dueDate: dueDate,
        isCompleted: _isCompleted,
        subTasks: _subTasks,
      );

      taskProvider.addTask(newTask);
    } else {
      final updatedTask = Task(
        id: widget.task!.id,
        title: _titleController.text,
        description: _descriptionController.text,
        categoryId: _selectedCategoryId,
        priority: _selectedPriority,
        dueDate: dueDate,
        isCompleted: _isCompleted,
        subTasks: _subTasks,
        createdAt: widget.task!.createdAt,
      );

      taskProvider.updateTask(updatedTask);
    }

    Navigator.pop(context);
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer la tâche'),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer cette tâche ? Cette action est irréversible.',
          ),
          actions: [
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text(
                'Supprimer',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Provider.of<TaskProvider>(
                  context,
                  listen: false,
                ).deleteTask(widget.task!.id);
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
