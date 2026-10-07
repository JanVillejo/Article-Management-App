import 'package:flutter/material.dart';
import '../models/article.dart';
import '../state/article_store.dart';
import '../widgets/article_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/feedback.dart';
import '../widgets/filter_sheet.dart';
import 'article_detail_screen.dart';
import 'article_editor_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _open(BuildContext context, Article article) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ArticleDetailScreen(article: article)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = ArticleScope.of(context);
    final articles = store.visible;
    final hasAny = store.total > 0;

    return Scaffold(
      // With no articles the empty state has its own button, so the
      // floating button would only repeat it.
      floatingActionButton: hasAny
          ? FloatingActionButton.extended(
              onPressed: () => openEditor(context),
              icon: const Icon(Icons.edit_rounded),
              label: const Text('New article'),
            )
          : null,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(title: const Text('Articles')),
          if (hasAny) ...const [
            SliverToBoxAdapter(child: _SearchRow()),
            SliverToBoxAdapter(child: _FilterChips()),
          ],
          if (!hasAny)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                searching: false,
                title: 'Your library is empty',
                message:
                    'Nothing to read yet. Write your first article and it will be saved right here on your device.',
                actionLabel: 'Write your first article',
                actionIcon: Icons.edit_rounded,
                onAction: () => openEditor(context),
              ),
            )
          else if (articles.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                searching: true,
                title: 'No articles match',
                message:
                    'We couldn\'t find anything with these filters. Try a different word, author, or category.',
                actionLabel: 'Clear filters',
                actionIcon: Icons.filter_alt_off_rounded,
                onAction: () {
                  store.clearFilters();
                  store.setSort(SortOrder.newest);
                },
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 104),
              sliver: SliverList.separated(
                itemCount: articles.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final article = articles[i];
                  return _SwipeToDelete(
                    key: ValueKey(article.id),
                    article: article,
                    child: ArticleCard(
                      article: article,
                      onTap: () => _open(context, article),
                      onEdit: () => openEditor(context, article: article),
                      onDelete: () async {
                        final ok = await confirmDelete(context, article);
                        if (ok && context.mounted) {
                          deleteWithUndo(context, article);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _SwipeToDelete extends StatelessWidget {
  const _SwipeToDelete({super.key, required this.article, required this.child});

  final Article article;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Dismissible(
        key: ValueKey('dismiss-${article.id}'),
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) => confirmDelete(context, article),
        onDismissed: (_) => deleteWithUndo(context, article),
        background: Container(
          color: scheme.errorContainer,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          child: Icon(Icons.delete_outline_rounded,
              color: scheme.onErrorContainer, size: 28),
        ),
        child: child,
      ),
    );
  }
}

class _SearchRow extends StatefulWidget {
  const _SearchRow();

  @override
  State<_SearchRow> createState() => _SearchRowState();
}

class _SearchRowState extends State<_SearchRow> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = ArticleScope.of(context);
    final scheme = Theme.of(context).colorScheme;

    // Keep the field in sync when filters are cleared elsewhere.
    if (store.query.isEmpty && _controller.text.isNotEmpty) {
      _controller.clear();
    }

    final count = store.sheetFilterCount;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: store.setQuery,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search title, author, or text',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _controller.clear();
                          store.setQuery('');
                        },
                      ),
                filled: true,
                fillColor: scheme.surfaceContainerHigh,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Badge(
            isLabelVisible: count > 0,
            label: Text('$count'),
            child: IconButton.filledTonal(
              tooltip: 'Filter and sort',
              icon: const Icon(Icons.tune_rounded),
              onPressed: () => showFilterSheet(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips();

  @override
  Widget build(BuildContext context) {
    final store = ArticleScope.of(context);
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          if (store.author != null) ...[
            InputChip(
              avatar: const Icon(Icons.person_outline_rounded, size: 18),
              label: Text(store.author!),
              onDeleted: () => store.setAuthor(null),
              deleteButtonTooltipMessage: 'Remove author filter',
            ),
            const SizedBox(width: 8),
          ],
          FilterChip(
            label: const Text('All'),
            selected: store.category == null,
            onSelected: (_) => store.setCategory(null),
          ),
          for (final c in kCategories) ...[
            const SizedBox(width: 8),
            FilterChip(
              label: Text(c),
              selected: store.category == c,
              onSelected: (selected) => store.setCategory(selected ? c : null),
            ),
          ],
        ],
      ),
    );
  }
}
