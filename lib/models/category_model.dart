import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final IconData icon;
  final String description;
  final int itemCount;
  final Color badgeColor;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.itemCount,
    required this.badgeColor,
  });
}
