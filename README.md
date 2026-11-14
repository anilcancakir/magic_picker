<p align="center">
  <img src="https://raw.githubusercontent.com/anilcancakir/magic_picker/master/.github/magic-logo.svg" width="120" alt="Magic Logo" />
</p>

<h1 align="center">Magic Picker</h1>

<p align="center">
  <strong>Pick a file, an image or a video and get a <code>MagicFile</code> back.</strong><br/>
  The <code>Pick</code> facade for Magic apps opens the gallery, camera, file dialog and save dialog on every platform, and <code>PickerServiceProvider</code> lets <code>Storage.download</code> open the share sheet on mobile and desktop.
</p>

<p align="center">
  <a href="https://pub.dev/packages/magic_picker"><img src="https://img.shields.io/pub/v/magic_picker.svg" alt="pub package"></a>
  <a href="https://github.com/anilcancakir/magic_picker/actions/workflows/ci.yml"><img src="https://img.shields.io/github/actions/workflow/status/anilcancakir/magic_picker/ci.yml?branch=master&label=CI" alt="CI"></a>
  <a href="https://codecov.io/gh/anilcancakir/magic_picker"><img src="https://codecov.io/gh/anilcancakir/magic_picker/graph/badge.svg" alt="codecov"></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License: MIT"></a>
  <a href="https://pub.dev/packages/magic_picker/score"><img src="https://img.shields.io/pub/points/magic_picker" alt="pub points"></a>
</p>

<p align="center">
  <a href="https://anilcancakir.com/magic_picker">Documentation</a> ·
  <a href="https://pub.dev/packages/magic_picker">pub.dev</a> ·
  <a href="https://github.com/anilcancakir/magic_picker/issues">Issues</a>
</p>

## At a glance

| Fact | Value |
|---|---|
| Package | [`magic_picker`](https://pub.dev/packages/magic_picker) |
| Install | `flutter pub add magic_picker`, then `dart run magic:dowel plugin:install magic_picker` |
| Import | `package:magic_picker/magic_picker.dart` |
| Entry points | `Pick` (facade), `PickerServiceProvider` (wiring, download handler), `XFile.toMagicFile()` and `MagicFile.toXFile()` (extensions); re-exports `XFile` and `CameraDevice` |
| Platforms | Android, iOS, web, macOS, Windows and Linux. The camera on desktop needs a custom `image_picker` delegate; `Pick.directory` is not available on the web. |
| Requires | Dart >=3.13, Flutter >=3.47, `magic` ^1.0.0 |
| Dependencies | `magic`, `file_picker`, `image_picker`, `share_plus`; dowel runs the installer |
| License | MIT |

## Install

```bash
flutter pub add magic_picker
dart run magic:dowel plugin:install magic_picker
```

The installer registers `PickerServiceProvider` in the `providers` list of `lib/config/app.dart`. It publishes no config: `Pick` needs no settings.

## Pick

Open a picker and store the result.

```dart
import 'package:magic_picker/magic_picker.dart';

Future<void> main() async {
  final image = await Pick.image(maxWidth: 1024, imageQuality: 85);
  if (image == null) return; // The user cancelled.

  await image.store('avatars/profile.jpg');
}
```

| Member | Returns | Meaning |
|--------|---------|---------|
| `Pick.image`, `Pick.media`, `Pick.video` | `Future<MagicFile?>` | One image, one image or video, one video from the gallery. |
| `Pick.images` | `Future<List<MagicFile>>` | Several images; empty on cancel. |
| `Pick.camera`, `Pick.recordVideo` | `Future<MagicFile?>` | A photo or a recording; `fallbackToGallery` and `onError` handle a refused permission. |
| `Pick.file`, `Pick.files` | `Future<MagicFile?>`, `Future<List<MagicFile>>` | One or several files, optionally filtered by `extensions`. |
| `Pick.directory` | `Future<String?>` | A directory path; not on the web. |
| `Pick.saveFile` | `Future<Uri?>` | Writes bytes through the save dialog; the `Uri` scheme is `file`, `content` or `blob` by platform. |

A cancelled pick answers `null` (a list: empty), never an error. File contents are read on demand, not at pick time.

## Download

`Storage.download` needs a handler on mobile and desktop, and `PickerServiceProvider` installs it.

```dart
import 'package:magic/magic.dart';

Future<void> main() async {
  await Storage.download('reports/2024.pdf', name: 'Annual Report.pdf');
}
```

| Platform | What happens |
|----------|--------------|
| Mobile and desktop | `PickerServiceProvider.boot()` sets `LocalAdapterContract.downloadHandler`; the file opens in the share sheet. |
| Web | A browser download. The handler is ignored. |
| Mobile or desktop without the plugin | `download` throws `UnsupportedError`, naming `magic_picker`. |

## XFile

`toMagicFile()` is a `Future` everywhere. `toXFile()` is synchronous on mobile and desktop, where it wraps the path, and a `Future` on the web, where it reads the bytes first. It throws `UnsupportedError` for a file with no path (IO) or no bytes (web).

## For AI coding agents

Rules for an agent writing code against this package. Each one is a mistake that costs a user a crash or a silent no-op.

| Do | Because |
|----|---------|
| Import only `package:magic_picker/magic_picker.dart` | Everything under `src/` is private; the barrel also exports `XFile` and `CameraDevice`. |
| Register `PickerServiceProvider` in `lib/config/app.dart` | It is not auto-registered, and without it `Storage.download` throws on mobile and desktop. |
| Treat a `null` or empty result as a cancelled pick | Cancelling is not an error. |
| Pass `onError` or `fallbackToGallery` to `Pick.camera` and `Pick.recordVideo` | Otherwise a refused camera permission rethrows. |
| Read `savedTo.scheme` before `toFilePath()` on a `Pick.saveFile` result | Only `file` uris convert; Android answers `content` and the web `blob`. |
| `await` `toXFile()` in code that also builds for the web | It is a `Future` there and synchronous elsewhere. |
| Do not pass `withData` to `Pick.file` or `Pick.files` | The parameter no longer exists; call `readAsBytes` on the result. |
| In a test, reset `LocalAdapterContract.downloadHandler` to `null` in `tearDown` | It is a static that `Magic.flush()` does not clear. |

## Dependencies

`magic` for the container, `MagicFile`, `Storage` and the service provider base class; `image_picker` for the gallery and camera; `file_picker` for files, directories and the save dialog; `share_plus` for the share sheet; dowel to run the installer through `dart run magic:dowel`.

## Links

- [Documentation](https://anilcancakir.com/magic_picker/docs/getting-started/installation): installation, `Pick`, `XFile` conversion, download and testing
- [API reference](https://pub.dev/documentation/magic_picker/latest/)
- [llms.txt](llms.txt) and the [agent skill](skills/magic-picker/SKILL.md) for AI coding agents: `npx skills add anilcancakir/magic_picker`
- [Changelog](CHANGELOG.md)
- [Report an issue](https://github.com/anilcancakir/magic_picker/issues)
- [Security policy](SECURITY.md)

## License

MIT, see [LICENSE](LICENSE). Built by [Anılcan Çakır](https://anilcancakir.com).
