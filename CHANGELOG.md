# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Changed

- **The README shows the plugin's own logo instead of the Magic logo.** `.github/logo.png`, a 512 pixel PNG of the mark the docs site serves, replaces `.github/magic-logo.svg`. (`README.md`, `.github/`)

## [1.0.1] - 2026-11-15

### Changed

- `Storage.download` on Linux opens the save dialog with the file's bytes instead of a share sheet, because `share_plus` cannot share a file there.
- The package page is `https://anilcancakir.com/magic/picker` and the documentation links sit under `https://anilcancakir.com/magic/docs/picker`.
- The README now has a short `XFile` sample.

### Fixed

- `Storage.download` no longer throws on Linux.
- `Pick.image`, `Pick.images`, `Pick.camera`, `Pick.media`, `Pick.video` and `Pick.recordVideo` results now carry a MIME type on Android and iOS, derived from the file name, so `upload` sends a content type.
- The `Pick.camera` and `Pick.recordVideo` fallback and `onError` behaviour is now covered by tests.
- The picker docs now say `path` is a `blob:` URL for image picks on the web, and the README and installation page list the `dowel` dependency.
- The docs and the `Pick.saveFile` API comment no longer say the web answers a `blob` URI: on the web the browser downloads the file and `saveFile` answers `null`.
- The `MagicFile.path` description says the path is present when the platform gives one, instead of promising it on every mobile pick.
- The Windows note on `Storage.download` names what `share_plus` does on a Windows older than 10 version 1809: it throws `UnimplementedError` for any file.

## [1.0.0] - 2026-11-14

### Added

- **Initial release.** File and image picking for Magic apps, moved out of `magic` core.
- `Pick` facade: `image`, `images`, `media`, `video`, `camera`, `recordVideo`, `file`, `files`, `directory` and `saveFile`, each returning a `MagicFile`.
- `PickerServiceProvider`, which sets the share-sheet download handler so `Storage.download` works on mobile and desktop.
- `XFile.toMagicFile()` and `MagicFile.toXFile()` conversion extensions; `XFile` and `CameraDevice` are re-exported.
- A `dowel` plugin provider (`MagicPickerDowelProvider`) that `dart run magic:dowel plugin:install magic_picker` registers.
- Built on `file_picker` ^13.3.3, `image_picker` ^1.2.4, `share_plus` ^13.3.1 and `dowel` ^1.0.0. Requires Dart 3.13, Flutter 3.47 and `magic` ^1.0.0.
