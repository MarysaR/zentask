import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';
import '../models/category.dart';
import '../config/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _categoryNameController;
  Color _selectedColor = AppTheme.lilacLight;
  IconData _selectedIcon = Icons.category;

  @override
  void initState() {
    super.initState();
    _categoryNameController = TextEditingController();
  }

  @override
  void dispose() {
    _categoryNameController.dispose();
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
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Statistiques
          _buildStatisticsSection(),
          const Divider(height: 32),

          // Gestion des catégories
          _buildCategoriesSection(),
          const Divider(height: 32),

          // À propos
          _buildAboutSection(),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        final stats = provider.getTaskStatistics();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistiques',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          'Total',
                          stats['totalTasks'].toString(),
                          Icons.list,
                          AppTheme.lilacLight,
                        ),
                        _buildStatItem(
                          'Terminées',
                          stats['completedTasks'].toString(),
                          Icons.check_circle,
                          AppTheme.anisLight,
                        ),
                        _buildStatItem(
                          'En cours',
                          stats['pendingTasks'].toString(),
                          Icons.pending,
                          Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    LinearProgressIndicator(
                      value:
                          (stats['totalTasks'] == 0)
                              ? 0
                              : stats['completedTasks'] / stats['totalTasks'],
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.anisLight,
                      ),
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      'Taux de complétion: ${stats['completionRate']}%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    if (stats['upcomingTasks'] > 0 ||
                        stats['overdueTasks'] > 0) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          if (stats['upcomingTasks'] > 0)
                            _buildStatItem(
                              'À venir',
                              stats['upcomingTasks'].toString(),
                              Icons.upcoming,
                              Colors.blue,
                            ),
                          if (stats['overdueTasks'] > 0)
                            _buildStatItem(
                              'En retard',
                              stats['overdueTasks'].toString(),
                              Icons.warning,
                              Colors.red,
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildCategoriesSection() {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        final categories = provider.categories;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Catégories',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter'),
                  onPressed: () => _showAddCategoryDialog(context),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.lilacLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            ...categories.map((category) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: category.color,
                    child: Icon(category.icon, color: Colors.white),
                  ),
                  title: Text(category.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed:
                            () => _showEditCategoryDialog(context, category),
                      ),

                      if (![
                        'personal',
                        'work',
                        'shopping',
                        'health',
                        'other',
                      ].contains(category.id))
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed:
                              () => _showDeleteCategoryConfirmation(
                                context,
                                category,
                              ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'À propos',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ZenTask',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Une application de gestion de tâches élégante et intuitive.',
                ),
                const SizedBox(height: 16),
                const Text(
                  'Version 1.0.0',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  '© 2025 MarysaR - Karukéra Digital',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    _categoryNameController.clear();
    _selectedColor = AppTheme.lilacLight;
    _selectedIcon = Icons.category;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Ajouter une catégorie'),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _categoryNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom de la catégorie',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un nom';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Sélecteur de couleur
                    const Text('Couleur'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildColorOption(AppTheme.lilacLight, setState),
                        _buildColorOption(AppTheme.anisLight, setState),
                        _buildColorOption(Colors.blue, setState),
                        _buildColorOption(Colors.red, setState),
                        _buildColorOption(Colors.orange, setState),
                        _buildColorOption(Colors.green, setState),
                        _buildColorOption(Colors.purple, setState),
                        _buildColorOption(Colors.teal, setState),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Sélecteur d'icône
                    const Text('Icône'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildIconOption(Icons.home, setState),
                        _buildIconOption(Icons.work, setState),
                        _buildIconOption(Icons.shopping_cart, setState),
                        _buildIconOption(Icons.favorite, setState),
                        _buildIconOption(Icons.book, setState),
                        _buildIconOption(Icons.fitness_center, setState),
                        _buildIconOption(Icons.restaurant, setState),
                        _buildIconOption(Icons.school, setState),
                        _buildIconOption(Icons.beach_access, setState),
                        _buildIconOption(Icons.category, setState),
                        _buildIconOption(Icons.attach_money, setState),
                        _buildIconOption(Icons.celebration, setState),
                      ],
                    ),
                  ],
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.lilacLight,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final taskProvider = Provider.of<TaskProvider>(
                        context,
                        listen: false,
                      );

                      final newCategory = Category(
                        name: _categoryNameController.text,
                        color: _selectedColor,
                        icon: _selectedIcon,
                      );

                      taskProvider.addCategory(newCategory);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Ajouter'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditCategoryDialog(BuildContext context, Category category) {
    _categoryNameController.text = category.name;
    _selectedColor = category.color;
    _selectedIcon = category.icon;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Modifier la catégorie'),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _categoryNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom de la catégorie',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un nom';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Sélecteur de couleur
                    const Text('Couleur'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildColorOption(AppTheme.lilacLight, setState),
                        _buildColorOption(AppTheme.anisLight, setState),
                        _buildColorOption(Colors.blue, setState),
                        _buildColorOption(Colors.red, setState),
                        _buildColorOption(Colors.orange, setState),
                        _buildColorOption(Colors.green, setState),
                        _buildColorOption(Colors.purple, setState),
                        _buildColorOption(Colors.teal, setState),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Sélecteur d'icône
                    const Text('Icône'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildIconOption(Icons.home, setState),
                        _buildIconOption(Icons.work, setState),
                        _buildIconOption(Icons.shopping_cart, setState),
                        _buildIconOption(Icons.favorite, setState),
                        _buildIconOption(Icons.book, setState),
                        _buildIconOption(Icons.fitness_center, setState),
                        _buildIconOption(Icons.restaurant, setState),
                        _buildIconOption(Icons.school, setState),
                        _buildIconOption(Icons.beach_access, setState),
                        _buildIconOption(Icons.category, setState),
                        _buildIconOption(Icons.attach_money, setState),
                        _buildIconOption(Icons.celebration, setState),
                      ],
                    ),
                  ],
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.lilacLight,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final taskProvider = Provider.of<TaskProvider>(
                        context,
                        listen: false,
                      );

                      final updatedCategory = category.copyWith(
                        name: _categoryNameController.text,
                        color: _selectedColor,
                        icon: _selectedIcon,
                      );

                      taskProvider.updateCategory(updatedCategory);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteCategoryConfirmation(
    BuildContext context,
    Category category,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer la catégorie'),
          content: Text(
            'Êtes-vous sûr de vouloir supprimer la catégorie "${category.name}" ? '
            'Les tâches associées à cette catégorie seront conservées mais n\'auront plus de catégorie assignée.',
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
                ).deleteCategory(category.id);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildColorOption(Color color, StateSetter setState) {
    final isSelected = _selectedColor == color;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color;
        });
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.transparent,
            width: 2,
          ),
        ),
        child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
      ),
    );
  }

  Widget _buildIconOption(IconData icon, StateSetter setState) {
    final isSelected = _selectedIcon.codePoint == icon.codePoint;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIcon = icon;
        });
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? _selectedColor : Colors.grey[200],
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: isSelected ? Colors.white : Colors.black54),
      ),
    );
  }
}
