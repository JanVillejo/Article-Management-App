import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'state/article_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = ArticleStore();
  await store.load(); // read saved articles before the first frame
  runApp(ArticleApp(store: store));
}

class ArticleApp extends StatefulWidget {
  const ArticleApp({super.key, required this.store});

  final ArticleStore store;

  @override
  State<ArticleApp> createState() => _ArticleAppState();
}

class _ArticleAppState extends State<ArticleApp> {
  @override
  void dispose() {
    widget.store.dispose();
    super.dispose();
  }

  ThemeData _theme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1F6F5C), // deep pine
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        scrolledUnderElevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ArticleScope(
      store: widget.store,
      child: MaterialApp(
        title: 'Articles',
        debugShowCheckedModeBanner: false,
        theme: _theme(Brightness.light),
        darkTheme: _theme(Brightness.dark),
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
