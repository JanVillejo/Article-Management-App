import 'dart:math' as math;
import 'package:flutter/material.dart';

const List<String> kCategories = [
  'Technology',
  'Design',
  'Lifestyle',
  'Business',
  'Other',
];

class CategoryStyle {
  const CategoryStyle(this.color, this.icon);
  final Color color;
  final IconData icon;
}

CategoryStyle styleFor(String category) {
  switch (category) {
    case 'Technology':
      return const CategoryStyle(Color(0xFF3B6FE0), Icons.memory_rounded);
    case 'Design':
      return const CategoryStyle(Color(0xFFD6457A), Icons.palette_rounded);
    case 'Lifestyle':
      return const CategoryStyle(Color(0xFF2E9E6B), Icons.spa_rounded);
    case 'Business':
      return const CategoryStyle(Color(0xFFD08A1E), Icons.trending_up_rounded);
    default:
      return const CategoryStyle(Color(0xFF6B7A90), Icons.article_rounded);
  }
}

class Article {
  const Article({
    required this.id,
    required this.title,
    required this.author,
    required this.body,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String author;
  final String body;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get wordCount => countWords(body);
  int get readingMinutes => readingTime(wordCount);

  String get excerpt => body.replaceAll(RegExp(r'\s+'), ' ').trim();

  String get authorInitial =>
      author.trim().isEmpty ? '?' : author.trim()[0].toUpperCase();

  Article copyWith({
    String? title,
    String? author,
    String? body,
    String? category,
    DateTime? updatedAt,
  }) {
    return Article(
      id: id,
      title: title ?? this.title,
      author: author ?? this.author,
      body: body ?? this.body,
      category: category ?? this.category,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'author': author,
        'body': body,
        'category': category,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Article.fromJson(Map<String, dynamic> json) => Article(
        id: json['id'] as String,
        title: json['title'] as String,
        author: (json['author'] as String?) ?? 'Unknown author',
        body: json['body'] as String,
        category: (json['category'] as String?) ?? 'Other',
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}

int countWords(String text) {
  final t = text.trim();
  return t.isEmpty ? 0 : t.split(RegExp(r'\s+')).length;
}

int readingTime(int words) => math.max(1, (words / 200).ceil());

String formatDate(DateTime d) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${months[d.month - 1]} ${d.day}, ${d.year}';
}
