import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/hive_database_service.dart';
import 'package:logging/logging.dart';

mixin CategoryProvider on ChangeNotifier {
  List<Category> _categories = [];
  final HiveDatabaseService _databaseService = HiveDatabaseService();
  final Logger _logger = Logger('CategoryProvider');

  List<Category> get categories => _categories;

  Future<void> loadCategories() async {
    try {
      _categories = await _databaseService.getCategories();
      notifyListeners();
    } catch (e) {
      _logger.warning('Erreur lors du chargement des catégories: $e');
    }
  }

  // Ajouter une catégorie
  Future<void> addCategory(Category category) async {
    try {
      await _databaseService.insertCategory(category);
      _categories.add(category);
      notifyListeners();
    } catch (e) {
      _logger.warning('Erreur lors de l\'ajout de la catégorie: $e');
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      await _databaseService.updateCategory(category);
      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = category;
        notifyListeners();
      }
    } catch (e) {
      _logger.warning('Erreur lors de la mise à jour de la catégorie: $e');
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _databaseService.deleteCategory(id);
      _categories.removeWhere((category) => category.id == id);
      notifyListeners();
    } catch (e) {
      _logger.warning('Erreur lors de la suppression de la catégorie: $e');
    }
  }
}
