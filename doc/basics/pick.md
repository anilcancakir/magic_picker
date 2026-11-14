# Pick

Open the system gallery, camera, file dialog and save dialog through the `Pick` facade and get a `MagicFile` back on every platform.

- [Basic Usage](#basic-usage)
- [Quick Reference](#quick-reference)
- [Images](#images)
- [Camera](#camera)
- [Video](#video)
- [Files](#files)
- [Saving a File](#saving-a-file)
- [Working with the Result](#working-with-the-result)
- [Platform Support](#platform-support)
- [Gotchas](#gotchas)
- [Related Documentation](#related-documentation)

<a name="basic-usage"></a>
## Basic Usage

```dart
import 'package:magic_picker/magic_picker.dart';

Future<void> main() async {
  final image = await Pick.image(maxWidth: 1024, imageQuality: 85);
  if (image == null) return; // The user cancelled.

  print('${image.name}: ${image.size} bytes');
  await image.store('avatars/profile.jpg');
}
```

`Pick` is a static facade over `image_picker` and `file_picker`. Every picker that returns a file answers with a `MagicFile` from core, or `null` (a list: empty) when the user cancels, so a cancelled pick is never an error.

<a name="quick-reference"></a>
## Quick Reference

| Member | Returns | Meaning |
|:-------|:--------|:--------|
| `Pick.image({maxWidth, maxHeight, imageQuality})` | `Future<MagicFile?>` | One image from the gallery. `imageQuality` is 0 to 100. |
| `Pick.images({maxWidth, maxHeight, imageQuality})` | `Future<List<MagicFile>>` | Several images from the gallery. |
| `Pick.camera({preferredCamera, maxWidth, maxHeight, imageQuality, fallbackToGallery, onError})` | `Future<MagicFile?>` | A photo from the camera. |
| `Pick.media({maxWidth, maxHeight, imageQuality})` | `Future<MagicFile?>` | One image or one video from the gallery. |
| `Pick.video({maxDuration})` | `Future<MagicFile?>` | One video from the gallery. |
| `Pick.recordVideo({preferredCamera, maxDuration, fallbackToGallery, onError})` | `Future<MagicFile?>` | A video recorded with the camera. |
| `Pick.file({extensions})` | `Future<MagicFile?>` | One file of any type, or of the listed extensions. |
| `Pick.files({extensions})` | `Future<List<MagicFile>>` | Several files. |
| `Pick.directory()` | `Future<String?>` | A directory path. Not supported on the web. |
| `Pick.saveFile({fileName, bytes, mimeType, dialogTitle})` | `Future<Uri?>` | Writes `bytes` through the save dialog and answers where they went. |

<a name="images"></a>
## Images

```dart
import 'package:magic_picker/magic_picker.dart';

Future<void> main() async {
  final image = await Pick.image(maxWidth: 800, maxHeight: 800);
  final gallery = await Pick.images(imageQuality: 80);

  print(image?.name);
  print(gallery.length); // 0 when the user cancels
}
```

`maxWidth` and `maxHeight` are pixel limits that shrink the picked image; leave them unset to keep the original. `imageQuality` is a number from 0 to 100.

<a name="camera"></a>
## Camera

```dart
import 'package:magic_picker/magic_picker.dart';

Future<void> main() async {
  final photo = await Pick.camera(
    preferredCamera: CameraDevice.front,
    fallbackToGallery: true,
    onError: (Object error) => print('Camera failed: $error'),
  );

  print(photo?.name);
}
```

`CameraDevice` is re-exported from this package, so no extra import is needed. When the camera fails, for example because the permission was refused, the outcome depends on two arguments:

| `onError` | `fallbackToGallery` | What happens on failure |
|:----------|:--------------------|:------------------------|
| unset | `false` | The error is rethrown. |
| set | `false` | `onError` runs and the call answers `null`. |
| either | `true` | `onError` runs when set, then the gallery picker opens. |

With `fallbackToGallery: true` the gallery also opens when the user closes the camera without a photo. `Pick.recordVideo` takes the same two arguments and falls back to `Pick.video`.

<a name="video"></a>
## Video

```dart
import 'package:magic_picker/magic_picker.dart';

Future<void> main() async {
  final clip = await Pick.video(maxDuration: const Duration(seconds: 30));
  final recording = await Pick.recordVideo(
    preferredCamera: CameraDevice.rear,
    maxDuration: const Duration(minutes: 1),
  );

  print(clip?.isVideo); // true
  print(recording?.name);
}
```

<a name="files"></a>
## Files

```dart
import 'package:magic_picker/magic_picker.dart';

Future<void> main() async {
  final anyFile = await Pick.file();
  final pdf = await Pick.file(extensions: ['pdf']);
  final documents = await Pick.files(extensions: ['pdf', 'doc', 'docx']);
  final directory = await Pick.directory();

  print([anyFile?.name, pdf?.name, documents.length, directory]);
}
```

`extensions` are written without the dot. Passing the list restricts the dialog to those types; leaving it out allows any file. File contents are not read at pick time: bytes load on demand through `readAsBytes`, so a large selection costs nothing until you store or upload it.

<a name="saving-a-file"></a>
## Saving a File

```dart
import 'dart:typed_data';

import 'package:magic_picker/magic_picker.dart';

Future<void> save(Uint8List pdfBytes) async {
  final savedTo = await Pick.saveFile(
    fileName: 'report.pdf',
    bytes: pdfBytes,
  );

  if (savedTo != null && savedTo.scheme == 'file') {
    print(savedTo.toFilePath());
  }
}
```

`saveFile` opens the platform save dialog, writes the bytes and answers the `Uri` it wrote to, or `null` when the user cancels. The scheme depends on the platform:

| Platform | Scheme |
|:---------|:-------|
| Desktop and iOS | `file` |
| Android | `content` (Storage Access Framework) |
| Web | `blob` |

Call `toFilePath()` only after checking for `file`. The MIME type comes from the extension of `fileName` (`report.pdf` becomes `application/pdf`) and falls back to `application/octet-stream`. Pass `mimeType` when the extension does not describe the content: Android and the browser both use it to choose the app that opens the file.

<a name="working-with-the-result"></a>
## Working with the Result

`MagicFile` is core's class; these are the members used most after a pick.

| Member | Meaning |
|:-------|:--------|
| `name`, `extension`, `mimeType` | The file name, its extension without the dot, and a MIME type derived from the name (`null` when the extension is unknown). |
| `size` | Bytes, filled for every pick. Treat `null` and `0` as unknown when you enforce an upload limit. |
| `path` | The file path on mobile and desktop; `null` on the web. |
| `isImage`, `isVideo` | Derived from the extension. |
| `readAsBytes()` | The bytes, read once and cached. |
| `store(path, {disk})`, `storeAs(directory, {disk})` | Write to `Storage`; `storeAs` generates a unique name. |
| `upload(url, {fieldName, data, headers})` | Send as multipart form data through `Http`. |

```dart
import 'package:magic_picker/magic_picker.dart';

Future<void> uploadAvatar() async {
  final image = await Pick.image(maxWidth: 512, imageQuality: 80);
  if (image == null) return;

  final response = await image.upload('/api/user/avatar', fieldName: 'avatar');
  print(response.successful);
}
```

<a name="platform-support"></a>
## Platform Support

| Method | Android | iOS | Web | Desktop |
|:-------|:--------|:----|:----|:--------|
| `image`, `images`, `media`, `video` | yes | yes | yes | yes |
| `camera`, `recordVideo` | yes | yes | yes | needs a custom `image_picker` camera delegate |
| `file`, `files`, `saveFile` | yes | yes | yes | yes |
| `directory` | yes | yes | no | yes |

Each platform's permission setup (photo library and camera usage descriptions on iOS and macOS, file-access entitlements on macOS) is the app's responsibility.

<a name="gotchas"></a>
## Gotchas

| Mistake | Fix |
|:--------|:----|
| Treating `null` as a failure | `null` is a cancelled pick. Return early. |
| Calling `Pick.camera` with no `onError` and no fallback | A refused permission rethrows. Pass one of the two. |
| Reading `path` on the web | It is `null` there; use `readAsBytes` or `store`. |
| Trusting `size` as a limit | It can be `null` or `0` when the file vanished after the pick. Check the stored size too. |
| Calling `savedTo.toFilePath()` without checking the scheme | Only `file` uris convert; `content` and `blob` throw. |
| Passing `withData` to `Pick.file` or `Pick.files` | The parameter no longer exists. Read bytes with `readAsBytes`. |
| Calling `Pick.directory` on the web | It is not supported there. |

<a name="related-documentation"></a>
## Related Documentation

- [XFile Conversion](./xfile.md): handing a picked file to code that speaks `XFile`.
- [Download](./download.md): sharing a stored file with `Storage.download`.
- [Testing](../guides/testing.md): testing code that calls `Pick`.
