# Article Manager

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
