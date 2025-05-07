import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../config/theme.dart';

part 'category.g.dart';

@HiveType(typeId: 0)
class Category extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int colorValue;

  @HiveField(3)
  int iconCodePoint;

  Category({
    String? id,
    required this.name,
    Color color = AppTheme.lilacLight,
    IconData icon = Icons.list,
  }) : id = id ?? const Uuid().v4(),
       colorValue = color.value,
       iconCodePoint = icon.codePoint;

  Color get color => Color(colorValue);

  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  Category copyWith({String? name, Color? color, IconData? icon}) {
    return Category(
      id: id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }

  static List<Category> getDefaultCategories() {
    return [
      Category(
        id: 'personal',
        name: 'Personnel',
        color: const Color.fromARGB(255, 161, 101, 235),
        icon: Icons.person,
      ),
      Category(
        id: 'work',
        name: 'Travail',
        color: const Color.fromARGB(255, 92, 161, 216),
        icon: Icons.work,
      ),
      Category(
        id: 'shopping',
        name: 'Courses',
        color: const Color.fromARGB(255, 112, 135, 78),
        icon: Icons.shopping_cart,
      ),
      Category(
        id: 'health',
        name: 'Santé',
        color: const Color(0xFFEF9A9A),
        icon: Icons.favorite,
      ),
      Category(
        id: 'other',
        name: 'Autre',
        color: const Color.fromARGB(255, 235, 161, 51),
        icon: Icons.category,
      ),
    ];
  }
}
