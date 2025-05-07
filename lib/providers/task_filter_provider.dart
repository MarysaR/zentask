import 'package:flutter/material.dart';
import '../models/task.dart';

mixin TaskFilterProvider on ChangeNotifier {
  String? _searchQuery;
  String? _selectedCategoryId;
  TaskPriority? _selectedPriority;
  bool? _selectedCompletionStatus;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  String? get searchQuery => _searchQuery;
  String? get selectedCategoryId => _selectedCategoryId;
  TaskPriority? get selectedPriority => _selectedPriority;
  bool? get selectedCompletionStatus => _selectedCompletionStatus;
  DateTime? get selectedStartDate => _selectedStartDate;
  DateTime? get selectedEndDate => _selectedEndDate;

  void setSearchQuery(String? query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void setSelectedPriority(TaskPriority? priority) {
    _selectedPriority = priority;
    notifyListeners();
  }

  void setSelectedCompletionStatus(bool? isCompleted) {
    _selectedCompletionStatus = isCompleted;
    notifyListeners();
  }

  void setSelectedDateRange(DateTime? startDate, DateTime? endDate) {
    _selectedStartDate = startDate;
    _selectedEndDate = endDate;
    notifyListeners();
  }

  void resetFilters() {
    _searchQuery = null;
    _selectedCategoryId = null;
    _selectedPriority = null;
    _selectedCompletionStatus = null;
    _selectedStartDate = null;
    _selectedEndDate = null;
    notifyListeners();
  }

  List<Task> filterTasks(List<Task> tasks) {
    List<Task> filteredTasks = List.from(tasks);

    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      filteredTasks =
          filteredTasks.where((task) {
            return task.title.toLowerCase().contains(
                  _searchQuery!.toLowerCase(),
                ) ||
                task.description.toLowerCase().contains(
                  _searchQuery!.toLowerCase(),
                );
          }).toList();
    }

    // Filtre par catégorie
    if (_selectedCategoryId != null) {
      filteredTasks =
          filteredTasks
              .where((task) => task.categoryId == _selectedCategoryId)
              .toList();
    }

    // Filtre par priorité
    if (_selectedPriority != null) {
      filteredTasks =
          filteredTasks
              .where((task) => task.priority == _selectedPriority)
              .toList();
    }

    // Filtre par statut de complétion
    if (_selectedCompletionStatus != null) {
      filteredTasks =
          filteredTasks
              .where((task) => task.isCompleted == _selectedCompletionStatus)
              .toList();
    }

    // Filtrer par plage de dates
    if (_selectedStartDate != null) {
      filteredTasks =
          filteredTasks
              .where(
                (task) =>
                    task.dueDate != null &&
                    task.dueDate!.isAfter(_selectedStartDate!),
              )
              .toList();
    }

    if (_selectedEndDate != null) {
      filteredTasks =
          filteredTasks
              .where(
                (task) =>
                    task.dueDate != null &&
                    task.dueDate!.isBefore(_selectedEndDate!),
              )
              .toList();
    }

    return filteredTasks;
  }
}
