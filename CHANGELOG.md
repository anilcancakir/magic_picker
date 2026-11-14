# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Changed

- The package page is `https://anilcancakir.com/magic/picker` and the documentation links sit under `https://anilcancakir.com/magic/docs/picker` (the pub.dev page carries it from the next release).
- `Storage.download` on Linux opens the save dialog with the file's bytes instead of a share sheet, because `share_plus` cannot share a file there.

### Fixed

- `Storage.download` no longer throws on Linux.
- `Pick.image`, `Pick.images`, `Pick.camera`, `Pick.media`, `Pick.video` and `Pick.recordVideo` results now carry a MIME type on Android and iOS, derived from the file name, so `upload` sends a content type.
- The `Pick.camera` and `Pick.recordVideo` fallback and `onError` behaviour is now covered by tests.
- The picker docs now say `path` is a `blob:` URL for image picks on the web, and the README and installation page list the `dowel` dependency.

## [1.0.0] - 2026-11-14

### Added

- **Initial release.** File and image picking for Magic apps, moved out of `magic` core.
- `Pick` facade: `image`, `images`, `media`, `video`, `camera`, `recordVideo`, `file`, `files`, `directory` and `saveFile`, each returning a `MagicFile`.
- `PickerServiceProvider`, which sets the share-sheet download handler so `Storage.download` works on mobile and desktop.
- `XFile.toMagicFile()` and `MagicFile.toXFile()` conversion extensions; `XFile` and `CameraDevice` are re-exported.
- A `dowel` plugin provider (`MagicPickerDowelProvider`) that `dart run magic:dowel plugin:install magic_picker` registers.
- Built on `file_picker` ^13.3.3, `image_picker` ^1.2.4, `share_plus` ^13.3.1 and `dowel` ^1.0.0. Requires Dart 3.13, Flutter 3.47 and `magic` ^1.0.0.
