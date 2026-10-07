import 'package:flutter/material.dart';
import '../models/article.dart';

class CategoryBadge extends StatelessWidget {
  const CategoryBadge({super.key, required this.category, this.size = 48});

  final String category;
  final double size;

  @override
  Widget build(BuildContext context) {
    final style = styleFor(category);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: style.color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(style.icon, color: style.color, size: size * 0.5),
    );
  }
}
