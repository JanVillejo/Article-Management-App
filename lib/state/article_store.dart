import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/article.dart';

enum SortOrder {
  newest('Newest'),
  oldest('Oldest'),
  title('Title A–Z');

  const SortOrder(this.label);
  final String label;
}

/// Holds all articles, saves every change to the device, and exposes
/// create / update / delete.
class ArticleStore extends ChangeNotifier {
  static const _storageKey = 'articles_v1';

  final List<Article> _articles = [];
  SharedPreferences? _prefs;
  String _query = '';
  String? _category;
  String? _author;
  SortOrder _sort = SortOrder.newest;

  String get query => _query;
  String? get category => _category;
  String? get author => _author;
  SortOrder get sort => _sort;
  int get total => _articles.length;

  /// Distinct author names, A to Z, for the author filter.
  List<String> get authors {
    final names = _articles.map((a) => a.author).toSet().toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return names;
  }

  /// Number of options set in the filter sheet (author, sort).
  int get sheetFilterCount =>
      (_author != null ? 1 : 0) + (_sort != SortOrder.newest ? 1 : 0);

  bool get isFiltering =>
      _query.trim().isNotEmpty || _category != null || _author != null;

  /// Loads saved articles. On the very first launch it adds a few samples.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;
    final raw = prefs.getString(_storageKey);
    if (raw == null) {
      _articles.addAll(_samples());
      await _save();
      return;
    }
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      _articles.addAll(
        list.map((e) => Article.fromJson(e as Map<String, dynamic>)),
      );
    } catch (_) {
      // Unreadable data: start empty rather than crash.
    }
  }

  Future<void> _save() async {
    final prefs = _prefs;
    if (prefs == null) return;
    final data = jsonEncode(_articles.map((a) => a.toJson()).toList());
    await prefs.setString(_storageKey, data);
  }

  void _changed() {
    // Drop the author filter if that author no longer has any articles.
    if (_author != null && !_articles.any((a) => a.author == _author)) {
      _author = null;
    }
    notifyListeners();
    unawaited(_save());
  }

  /// Author of the most recently edited article, used to prefill the form.
  String get defaultAuthor {
    if (_articles.isEmpty) return '';
    final sorted = [..._articles]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted.first.author;
  }

  List<Article> get visible {
    final q = _query.trim().toLowerCase();
    final list = _articles.where((a) {
      final matchesCategory = _category == null || a.category == _category;
      final matchesAuthor = _author == null || a.author == _author;
      final matchesQuery = q.isEmpty ||
          a.title.toLowerCase().contains(q) ||
          a.author.toLowerCase().contains(q) ||
          a.body.toLowerCase().contains(q);
      return matchesCategory && matchesAuthor && matchesQuery;
    }).toList();
    switch (_sort) {
      case SortOrder.newest:
        list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      case SortOrder.oldest:
        list.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
      case SortOrder.title:
        list.sort(
            (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    }
    return list;
  }

  Article? byId(String id) {
    for (final a in _articles) {
      if (a.id == id) return a;
    }
    return null;
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void setCategory(String? value) {
    _category = value;
    notifyListeners();
  }

  void setAuthor(String? value) {
    _author = value;
    notifyListeners();
  }

  void setSort(SortOrder value) {
    _sort = value;
    notifyListeners();
  }

  void resetSheetFilters() {
    _author = null;
    _sort = SortOrder.newest;
    notifyListeners();
  }

  void clearFilters() {
    _query = '';
    _category = null;
    _author = null;
    notifyListeners();
  }

  void add({
    required String title,
    required String author,
    required String body,
    required String category,
  }) {
    final now = DateTime.now();
    _articles.add(Article(
      id: now.microsecondsSinceEpoch.toString(),
      title: title,
      author: author,
      body: body,
      category: category,
      createdAt: now,
      updatedAt: now,
    ));
    _changed();
  }

  void update(Article article) {
    final i = _articles.indexWhere((a) => a.id == article.id);
    if (i == -1) return;
    _articles[i] = article.copyWith(updatedAt: DateTime.now());
    _changed();
  }

  void delete(String id) {
    _articles.removeWhere((a) => a.id == id);
    _changed();
  }

  void restore(Article article) {
    if (byId(article.id) != null) return;
    _articles.add(article);
    _changed();
  }

  List<Article> _samples() {
    final now = DateTime.now();
    return [
      Article(
        id: 'seed-1',
        title: 'Why small apps teach the biggest lessons',
        author: 'Ana Reyes',
        category: 'Technology',
        body:
            'Building a small app end to end forces you to make every decision yourself: how data flows, what happens when a list is empty, how an error should read. None of these are hard on their own, but together they are the difference between a demo and a product.\n\nStart with one screen that does one job well. Add a second screen only when the first one starts to feel crowded. Keep a short list of rough edges as you go, and fix the ones people would notice first.',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(hours: 3)),
      ),
      Article(
        id: 'seed-2',
        title: 'Designing empty states people actually use',
        author: 'Miguel Santos',
        category: 'Design',
        body:
            'An empty screen is the first thing a new user sees, so it should say what belongs here and how to add it. Skip the clever illustration if it does not help. A short sentence and a clear button do more work.\n\nWhen the emptiness comes from a search or a filter, say so, and offer a way to clear it.',
        createdAt: now.subtract(const Duration(days: 4)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      Article(
        id: 'seed-3',
        title: 'A calmer morning routine in four steps',
        author: 'Liza Cruz',
        category: 'Lifestyle',
        body:
            'Decide the night before what you will wear and what you will eat. Keep your phone out of reach for the first twenty minutes. Drink water before coffee. Write down the one thing that would make today a good day.\n\nNone of this is dramatic. That is the point: a routine you can repeat beats an ambitious one you abandon by Thursday.',
        createdAt: now.subtract(const Duration(days: 6)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      Article(
        id: 'seed-4',
        title: 'Pricing a side project for the first time',
        author: 'Paolo Dizon',
        category: 'Business',
        body:
            'Most first-time makers price too low because they price against their own time. Price against the problem you solve instead. Ask three people what the problem costs them today, then charge a fraction of that.\n\nOffer one plan at first. Every extra tier is another decision for the customer and another thing for you to maintain.',
        createdAt: now.subtract(const Duration(days: 9)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
    ];
  }
}

/// Makes the store available to every screen without extra packages.
class ArticleScope extends InheritedNotifier<ArticleStore> {
  const ArticleScope({
    super.key,
    required ArticleStore store,
    required super.child,
  }) : super(notifier: store);

  static ArticleStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ArticleScope>();
    assert(scope != null, 'ArticleScope not found above this widget');
    return scope!.notifier!;
  }
}
