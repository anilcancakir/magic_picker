# magic_picker example

A Magic app with one button. `Pick an image` runs `Pick.image` and shows the name, size and MIME type of the `MagicFile` it returns, or a note when you dismiss the picker.

```bash
cd example
flutter create --platforms=web .
flutter run -d chrome
```

`flutter create` adds the platform folder once; it leaves `lib/` and `pubspec.yaml` as they are. On iOS and macOS the app also needs the photo library usage description in `Info.plist` before the gallery opens.
