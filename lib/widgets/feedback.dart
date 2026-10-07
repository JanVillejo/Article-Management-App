import 'package:flutter/material.dart';
import '../models/article.dart';
import '../state/article_store.dart';

void showMessage(ScaffoldMessengerState messenger, String text) {
  messenger
    ..clearSnackBars()
    ..showSnackBar(SnackBar(
      content: Text(text),
      behavior: SnackBarBehavior.floating,
    ));
}

/// Asks permission before an article is deleted. Returns true only if the
/// person taps Delete.
Future<bool> confirmDelete(BuildContext context, Article article) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: Icon(Icons.delete_outline_rounded,
          color: Theme.of(ctx).colorScheme.error),
      title: const Text('Delete this article?'),
      content: Text(
        '"${article.title}" by ${article.author} will be removed from this device.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(ctx).colorScheme.error,
            foregroundColor: Theme.of(ctx).colorScheme.onError,
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Call after the person has confirmed. Deletes and offers a short Undo.
void deleteWithUndo(BuildContext context, Article article) {
  final store = ArticleScope.of(context);
  final messenger = ScaffoldMessenger.of(context);
  store.delete(article.id);
  messenger
    ..clearSnackBars()
    ..showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(
        'Deleted "${article.title}"',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () => store.restore(article),
      ),
    ));
}
