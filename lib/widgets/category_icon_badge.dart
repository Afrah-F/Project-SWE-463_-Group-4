import 'package:flutter/material.dart';

import '../models/budget_category.dart';
import '../utils/icon_registry.dart';

/// Colored circle with the category icon.
class CategoryIconBadge extends StatelessWidget {
  final BudgetCategory? category;
  final double size;

  const CategoryIconBadge({super.key, required this.category, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final color = Color(category?.colorValue ?? 0xFF8A8F8C);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(
        iconForKey(category?.iconKey ?? 'other'),
        color: Colors.white,
        size: size * 0.5,
      ),
    );
  }
}
