import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/article.dart';
import '../state/article_store.dart';
import '../widgets/category_badge.dart';
import '../widgets/feedback.dart';
import 'article_editor_screen.dart';

class ArticleDetailScreen extends StatefulWidget {
  const ArticleDetailScreen({super.key, required this.article});

  final Article article;

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  // Keeps showing the article while the page animates away after deleting.
  late Article _last = widget.article;

  Future<void> _delete(Article article) async {
    final confirmed = await confirmDelete(context, article);
    if (!confirmed || !mounted) return;
    deleteWithUndo(context, article);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final store = ArticleScope.of(context);
    final article = store.byId(widget.article.id) ?? _last;
    _last = article;

    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final style = styleFor(article.category);
    final edited =
        formatDate(article.updatedAt) != formatDate(article.createdAt);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => openEditor(context, article: article),
          ),
          IconButton(
            tooltip: 'Delete',
            icon: Icon(Icons.delete_outline_rounded, color: scheme.error),
            onPressed: () => _delete(article),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
              children: [
                Row(
                  children: [
                    Hero(
                      tag: 'badge-${article.id}',
                      child: CategoryBadge(category: article.category, size: 44),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      article.category,
                      style: text.titleSmall?.copyWith(
                        color: style.color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  article.title,
                  style: GoogleFonts.newsreader(
                    textStyle: text.headlineLarge,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: style.color.withValues(alpha: 0.16),
                      child: Text(
                        article.authorInitial,
                        style: text.labelLarge?.copyWith(
                          color: style.color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article.author,
                            style: text.titleSmall,
                          ),
                          Text(
                            'Published ${formatDate(article.createdAt)}  ·  ${article.readingMinutes} min read',
                            style: text.bodySmall
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                          if (edited)
                            Text(
                              'Edited ${formatDate(article.updatedAt)}',
                              style: text.bodySmall
                                  ?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Divider(color: scheme.outlineVariant),
                const SizedBox(height: 20),
                SelectableText(
                  article.body,
                  style: GoogleFonts.newsreader(
                    textStyle: text.bodyLarge,
                    fontSize: 19,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
