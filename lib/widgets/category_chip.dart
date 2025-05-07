import 'package:flutter/material.dart';
import '../models/category.dart';
import '../config/theme.dart';

class CategoryChip extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        child: Chip(
          avatar: CircleAvatar(
            backgroundColor: isSelected ? Colors.white : category.color,
            child: Icon(
              category.icon,
              size: 16,
              color: isSelected ? category.color : Colors.white,
            ),
          ),
          label: Text(category.name),
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          backgroundColor: isSelected ? category.color : Colors.white,
          side: BorderSide(color: category.color, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
      ),
    );
  }
}

class AllCategoriesChip extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const AllCategoriesChip({
    super.key,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        child: Chip(
          avatar: CircleAvatar(
            backgroundColor: isSelected ? Colors.white : AppTheme.lilacLight,
            child: Icon(
              Icons.list,
              size: 16,
              color: isSelected ? AppTheme.lilacLight : Colors.white,
            ),
          ),
          label: const Text('Toutes'),
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          backgroundColor: isSelected ? AppTheme.lilacLight : Colors.white,
          side: BorderSide(color: AppTheme.lilacLight, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
      ),
    );
  }
}

class CategoryChipList extends StatelessWidget {
  final List<Category> categories;
  final String? selectedCategoryId;
  final Function(String?) onCategorySelected;

  const CategoryChipList({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // Puce "Toutes les catégories"
          AllCategoriesChip(
            isSelected: selectedCategoryId == null,
            onTap: () => onCategorySelected(null),
          ),
          // Puces pour chaque catégorie
          ...categories.map(
            (category) => CategoryChip(
              category: category,
              isSelected: selectedCategoryId == category.id,
              onTap: () => onCategorySelected(category.id),
            ),
          ),
        ],
      ),
    );
  }
}
