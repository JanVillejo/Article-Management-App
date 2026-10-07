import 'package:flutter/material.dart';
import '../state/article_store.dart';

Future<void> showFilterSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _FilterSheet(),
  );
}

class _FilterSheet extends StatelessWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context) {
    final store = ArticleScope.of(context);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final authors = store.authors;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Filter and sort', style: text.titleLarge),
            const SizedBox(height: 20),
            Text('Author',
                style: text.labelLarge?.copyWith(color: scheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('All authors'),
                  selected: store.author == null,
                  showCheckmark: false,
                  onSelected: (_) => store.setAuthor(null),
                ),
                for (final name in authors)
                  ChoiceChip(
                    avatar: CircleAvatar(
                      backgroundColor: scheme.primary.withValues(alpha: 0.15),
                      child: Text(
                        name.isEmpty ? '?' : name[0].toUpperCase(),
                        style: text.labelSmall?.copyWith(color: scheme.primary),
                      ),
                    ),
                    label: Text(name),
                    selected: store.author == name,
                    showCheckmark: false,
                    onSelected: (_) => store.setAuthor(name),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Sort by',
                style: text.labelLarge?.copyWith(color: scheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<SortOrder>(
                showSelectedIcon: false,
                segments: [
                  for (final o in SortOrder.values)
                    ButtonSegment(value: o, label: Text(o.label)),
                ],
                selected: {store.sort},
                onSelectionChanged: (s) => store.setSort(s.first),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                TextButton(
                  onPressed:
                      store.sheetFilterCount == 0 ? null : store.resetSheetFilters,
                  child: const Text('Reset'),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Show ${store.visible.length} '
                      '${store.visible.length == 1 ? 'article' : 'articles'}'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
