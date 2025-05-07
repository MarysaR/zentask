import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../config/theme.dart';
import '../utils/validators.dart'; // Ajout de l'import pour validators.dart

class TaskForm extends StatefulWidget {
  final Task? task;
  final Function(Task) onSave;

  const TaskForm({super.key, this.task, required this.onSave});

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
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

    _subTasks = List.from(widget.task?.subTasks ?? []);

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

    if (_selectedCategoryId.isEmpty && categories.isNotEmpty) {
      _selectedCategoryId = widget.task?.categoryId ?? categories.first.id;
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Titre - Utilisation de Validators
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Titre',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: Validators.validateTitle, // Utilisation du validateur
          ),
          const SizedBox(height: 16),

          // Description - Utilisation de Validators
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Description (optionnelle)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            maxLines: 3,
            validator:
                Validators.validateDescription, // Utilisation du validateur
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _selectedCategoryId,
            decoration: InputDecoration(
              labelText: 'Catégorie',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
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
              Wrap(
                spacing: 8,
                children: [
                  _buildPriorityChip(TaskPriority.low, 'Basse', Colors.green),
                  _buildPriorityChip(
                    TaskPriority.medium,
                    'Moyenne',
                    Colors.orange,
                  ),
                  _buildPriorityChip(TaskPriority.high, 'Haute', Colors.red),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

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
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDate != null
                              ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                              : 'Aucune',
                        ),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap:
                      _selectedDate != null ? () => _selectTime(context) : null,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Heure',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
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

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: SwitchListTile(
              title: const Text('Tâche terminée'),
              value: _isCompleted,
              onChanged: (value) {
                setState(() {
                  _isCompleted = value;
                });
              },
              activeColor: AppTheme.lilacLight,
            ),
          ),
          const SizedBox(height: 24),

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
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addSubTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lilacLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_subTasks.isNotEmpty) ...[
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _subTasks.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final subTask = _subTasks[index];
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
                            subTask.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                        color:
                            subTask.isCompleted ? Colors.grey : Colors.black87,
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
                },
              ),
            ),
            const SizedBox(height: 24),
          ],

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
    );
  }

  Widget _buildPriorityChip(TaskPriority priority, String label, Color color) {
    final isSelected = _selectedPriority == priority;
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      backgroundColor: Colors.white,
      selectedColor: color,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
      onSelected: (selected) {
        setState(() {
          _selectedPriority = priority;
        });
      },
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
    // Validation de la sous-tâche avec Validators
    final validationResult = Validators.validateSubTaskTitle(
      _subTaskController.text,
    );

    if (validationResult != null) {
      // Afficher un message d'erreur
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(validationResult)));
      return;
    }

    setState(() {
      _subTasks.add(
        SubTask(title: _subTaskController.text, isCompleted: false),
      );
      _subTaskController.clear();
    });
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) return;

    // Validation supplémentaire de la date
    final dueDateError = Validators.validateDueDate(_selectedDate);
    if (dueDateError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(dueDateError)));
      return;
    }

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

      widget.onSave(newTask);
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

      widget.onSave(updatedTask);
    }
  }
}
