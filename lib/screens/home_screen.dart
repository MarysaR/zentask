import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../widgets/task_title.dart';
import '../config/theme.dart';
import 'task.screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return Scaffold(
      backgroundColor:
          isDarkMode
              ? AppTheme.darkBackgroundColor
              : AppTheme.lightBackgroundColor,
      appBar: AppBar(
        title: const Text('ZenTask'),
        actions: [
          IconButton(
            icon: Icon(
              Provider.of<ThemeProvider>(context).isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [_buildCategoryFilter(), Expanded(child: _buildTaskList())],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToTaskScreen(context),
        backgroundColor: AppTheme.anisLight,
        foregroundColor: Colors.black87,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        return Container(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: provider.categories.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildCategoryChip(
                  null,
                  'Toutes',
                  AppTheme.lilacLight,
                  Icons.list,
                  provider.selectedCategoryId == null,
                  provider,
                );
              } else {
                final category = provider.categories[index - 1];
                return _buildCategoryChip(
                  category.id,
                  category.name,
                  category.color,
                  category.icon,
                  provider.selectedCategoryId == category.id,
                  provider,
                );
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip(
    String? id,
    String name,
    Color color,
    IconData icon,
    bool isSelected,
    TaskProvider provider,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        selected: isSelected,
        label: Text(name),
        avatar: Icon(icon, color: isSelected ? Colors.white : color),
        backgroundColor: Colors.white,
        selectedColor: color,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        onSelected: (selected) {
          provider.setSelectedCategory(selected ? id : null);
        },
      ),
    );
  }

  Widget _buildTaskList() {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final tasks = provider.tasks;

        if (tasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 80,
                  color: AppTheme.lilacLight.withAlpha(50),
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucune tâche',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Appuyez sur + pour ajouter une tâche',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TaskTile(
                task: task,
                onTap: () => _navigateToTaskScreen(context, task: task),
                onToggleCompletion: () {
                  provider.toggleTaskCompletion(task.id);
                },
              ),
            );
          },
        );
      },
    );
  }

  void _navigateToTaskScreen(BuildContext context, {Task? task}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskScreen(task: task)),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rechercher'),
          content: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher des tâches...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[200],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: const Text('Rechercher'),
              onPressed: () {
                Provider.of<TaskProvider>(
                  context,
                  listen: false,
                ).setSearchQuery(_searchController.text);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showFilterDialog(BuildContext context) {
    TaskPriority? selectedPriority;
    bool? selectedCompletionStatus;
    DateTime? startDate;
    DateTime? endDate;

    final provider = Provider.of<TaskProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Filtrer les tâches'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Priorité',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildPriorityChip(
                          null,
                          'Toutes',
                          Colors.grey,
                          selectedPriority,
                          (value) => setState(() => selectedPriority = value),
                        ),
                        _buildPriorityChip(
                          TaskPriority.high,
                          'Haute',
                          Colors.red,
                          selectedPriority,
                          (value) => setState(() => selectedPriority = value),
                        ),
                        _buildPriorityChip(
                          TaskPriority.medium,
                          'Moyenne',
                          Colors.orange,
                          selectedPriority,
                          (value) => setState(() => selectedPriority = value),
                        ),
                        _buildPriorityChip(
                          TaskPriority.low,
                          'Basse',
                          Colors.green,
                          selectedPriority,
                          (value) => setState(() => selectedPriority = value),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Statut',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildStatusChip(
                          null,
                          'Tous',
                          Colors.grey,
                          selectedCompletionStatus,
                          (value) =>
                              setState(() => selectedCompletionStatus = value),
                        ),
                        _buildStatusChip(
                          false,
                          'À faire',
                          AppTheme.lilacLight,
                          selectedCompletionStatus,
                          (value) =>
                              setState(() => selectedCompletionStatus = value),
                        ),
                        _buildStatusChip(
                          true,
                          'Terminées',
                          AppTheme.anisLight,
                          selectedCompletionStatus,
                          (value) =>
                              setState(() => selectedCompletionStatus = value),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Date d\'échéance',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      title: Text(
                        startDate != null
                            ? 'Du: ${_formatDate(startDate!)}'
                            : 'Date de début',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (date != null) {
                          setState(() => startDate = date);
                        }
                      },
                    ),
                    ListTile(
                      title: Text(
                        endDate != null
                            ? 'Au: ${_formatDate(endDate!)}'
                            : 'Date de fin',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (date != null) {
                          setState(() => endDate = date);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Réinitialiser'),
                  onPressed: () {
                    provider.resetFilters();
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: const Text('Annuler'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                ElevatedButton(
                  child: const Text('Appliquer'),
                  onPressed: () {
                    provider.setSelectedPriority(selectedPriority);
                    provider.setSelectedCompletionStatus(
                      selectedCompletionStatus,
                    );
                    provider.setSelectedDateRange(startDate, endDate);
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPriorityChip(
    TaskPriority? priority,
    String label,
    Color color,
    TaskPriority? selectedPriority,
    Function(TaskPriority?) onSelected,
  ) {
    final isSelected = selectedPriority == priority;
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      backgroundColor: Colors.white,
      selectedColor: color,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
      onSelected: (selected) {
        onSelected(selected ? priority : null);
      },
    );
  }

  Widget _buildStatusChip(
    bool? status,
    String label,
    Color color,
    bool? selectedStatus,
    Function(bool?) onSelected,
  ) {
    final isSelected = selectedStatus == status;
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      backgroundColor: Colors.white,
      selectedColor: color,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
      onSelected: (selected) {
        onSelected(selected ? status : null);
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
