# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

## [0.0.1] - 2026-11-14

### Added

- **First release.** File and image picking for Magic apps, moved out of `magic` core 0.1.0.
- `Pick` facade: `image`, `images`, `media`, `video`, `camera`, `recordVideo`, `file`, `files`, `directory` and `saveFile`, each returning a `MagicFile`.
- `PickerServiceProvider`, which sets the share-sheet download handler so `Storage.download` works on mobile and desktop.
- `XFile.toMagicFile()` and `MagicFile.toXFile()` conversion extensions; `XFile` and `CameraDevice` are re-exported.
- A `dowel` plugin provider (`MagicPickerDowelProvider`) that `dart run magic:dowel plugin:install magic_picker` registers.
- Built on `file_picker` ^13.3.3, `image_picker` ^1.2.4, `share_plus` ^13.3.1 and `dowel` ^0.0.21. Requires Dart 3.13, Flutter 3.47 and `magic` ^0.1.0.
