import 'package:flutter/material.dart';

/// Icons a category can use. Categories store only the key.
const Map<String, IconData> kCategoryIcons = {
  'food': Icons.restaurant,
  'transport': Icons.directions_bus,
  'housing': Icons.home,
  'subscriptions': Icons.subscriptions,
  'course': Icons.menu_book,
  'coffee': Icons.local_cafe,
  'health': Icons.favorite,
  'bolt': Icons.bolt,
  'car': Icons.directions_car,
  'other': Icons.sell,
};

/// The seven-color category palette from the Phase 2 design.
const List<int> kCategoryColors = [
  0xFFC17B4A, // terracotta
  0xFF5F8296, // slate blue
  0xFF3F6B55, // deep green
  0xFF9575B5, // violet
  0xFFC4A94A, // mustard
  0xFF8A6552, // brown
  0xFF7E9C86, // sage
];

IconData iconForKey(String key) => kCategoryIcons[key] ?? Icons.sell;
