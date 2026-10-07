import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/article.dart';
import '../state/article_store.dart';
import '../widgets/feedback.dart';

Future<void> openEditor(BuildContext context, {Article? article}) {
  return Navigator.of(context).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => ArticleEditorScreen(article: article),
    ),
  );
}

class ArticleEditorScreen extends StatefulWidget {
  const ArticleEditorScreen({super.key, this.article});

  /// When null, the screen creates a new article.
  final Article? article;

  @override
  State<ArticleEditorScreen> createState() => _ArticleEditorScreenState();
}

class _ArticleEditorScreenState extends State<ArticleEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _author;
  late final TextEditingController _body;
  late String _category;
  bool _saved = false;

  bool get _isEditing => widget.article != null;

  bool get _dirty {
    final a = widget.article;
    if (a == null) {
      return _title.text.trim().isNotEmpty || _body.text.trim().isNotEmpty;
    }
    return _title.text.trim() != a.title ||
        _author.text.trim() != a.author ||
        _body.text.trim() != a.body ||
        _category != a.category;
  }

  @override
  void initState() {
    super.initState();
    final a = widget.article;
    _title = TextEditingController(text: a?.title ?? '');
    final suggested = context
            .getInheritedWidgetOfExactType<ArticleScope>()
            ?.notifier
            ?.defaultAuthor ??
        '';
    _author = TextEditingController(text: a?.author ?? suggested);
    _body = TextEditingController(text: a?.body ?? '');
    _category = a?.category ?? kCategories.first;
    _title.addListener(_refresh);
    _author.addListener(_refresh);
    _body.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _title.dispose();
    _author.dispose();
    _body.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final store = ArticleScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final title = _title.text.trim();
    final author = _author.text.trim();
    final body = _body.text.trim();

    if (_isEditing) {
      store.update(widget.article!.copyWith(
          title: title, author: author, body: body, category: _category));
    } else {
      store.add(
          title: title, author: author, body: body, category: _category);
    }

    _saved = true;
    Navigator.of(context).pop();
    showMessage(messenger, _isEditing ? 'Changes saved' : 'Article published');
  }

  Future<bool> _confirmDiscard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('Your edits have not been saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return discard ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final words = countWords(_body.text);

    return PopScope(
      canPop: _saved || !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final discard = await _confirmDiscard();
        if (discard && mounted) {
          _saved = true; // allow the pop below
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Close',
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(_isEditing ? 'Edit article' : 'New article'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FilledButton(
                onPressed: _save,
                child: Text(_isEditing ? 'Save changes' : 'Publish'),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                TextFormField(
                  controller: _title,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  maxLines: null,
                  style: GoogleFonts.newsreader(
                    textStyle: text.headlineMedium,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Title',
                    border: InputBorder.none,
                  ),
                  validator: (v) {
                    final t = (v ?? '').trim();
                    if (t.isEmpty) return 'Add a title';
                    if (t.length < 3) return 'Use at least 3 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _author,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Author',
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    filled: true,
                    fillColor: scheme.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (v) {
                    final t = (v ?? '').trim();
                    if (t.isEmpty) return 'Add the author\'s name';
                    if (t.length < 2) return 'Use at least 2 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Text('Category',
                    style: text.labelLarge
                        ?.copyWith(color: scheme.onSurfaceVariant)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final c in kCategories)
                      ChoiceChip(
                        avatar: Icon(
                          styleFor(c).icon,
                          size: 18,
                          color: _category == c
                              ? scheme.onSecondaryContainer
                              : styleFor(c).color,
                        ),
                        label: Text(c),
                        selected: _category == c,
                        showCheckmark: false,
                        onSelected: (_) => setState(() => _category = c),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _body,
                  textCapitalization: TextCapitalization.sentences,
                  keyboardType: TextInputType.multiline,
                  minLines: 12,
                  maxLines: null,
                  style: GoogleFonts.newsreader(
                    textStyle: text.bodyLarge,
                    fontSize: 18,
                    height: 1.6,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Start writing…',
                    filled: true,
                    fillColor: scheme.surfaceContainerLow,
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (v) {
                    final t = (v ?? '').trim();
                    if (t.isEmpty) return 'Write something before publishing';
                    if (countWords(t) < 5) return 'Use at least 5 words';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '$words ${words == 1 ? 'word' : 'words'} · ${readingTime(words)} min read',
                    style: text.labelMedium
                        ?.copyWith(color: scheme.onSurfaceVariant),
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
