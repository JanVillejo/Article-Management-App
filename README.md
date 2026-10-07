# Article Manager

Name: Jan Antonette F. Villejo
Stack Chosen: Flutter
Time started: 10AM
Time ended: 12PM
Partially done.

A small Flutter app to create, view, edit, and delete articles. Each article has a title, author, category, and body. Everything is saved on the device.

## Run it

```bash
flutter create .        # generates android/ios/web folders (keeps lib/ and pubspec.yaml)
flutter pub get
flutter run
```

Requires Flutter 3.27 or newer.

## Notes

- Articles are saved with `shared_preferences` as JSON (see `lib/state/article_store.dart`).
- Four sample articles are added on first launch only.
- Deleting always asks for confirmation, then offers Undo.
- Filter by category (chips) and author, and sort by newest, oldest, or title, from the filter button next to search.
- Friendly empty states appear when there are no articles and when filters match nothing.

**Architecture**

I split the code into four folders by job:
- `models/` holds the `Article` data class.
- `state/` holds the `ArticleStore`, which has all the app logic: create, edit, delete, search, filters, and saving.
- `screens/` holds the three full pages.
- `widgets/` holds the reusable pieces.

The screens only show what the store gives them and tell it what the user did. I did this so the logic is in one place and the screens stay easy to change. It's a light version of the MVVM idea.

**State management**

I used Flutter's built-in tools, a `ChangeNotifier` plus an `InheritedNotifier` (the `ArticleScope` class). When the store changes, the screens that read it rebuild. For an app this small, that's enough, and you don't have to learn a package like Provider or Riverpod first. If the app grows, moving to one of those is straightforward.

**Libraries**

- **Flutter Material 3:** the standard look and ready-made parts like chips, dialogs, and bottom sheets, with light and dark mode for free.
- **`shared_preferences`:** saves the articles as JSON on the device. It's the simplest way to make data persistent. For thousands of articles you'd switch to a database such as SQLite.
- **`google_fonts`:** gives the articles a serif font so they read like articles. It's the only purely visual dependency, so it's easy to remove.

I kept the dependencies to these two on purpose, so setup is quick and there's less that can break.
