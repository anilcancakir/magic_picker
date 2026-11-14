# XFile Conversion

Move between `MagicFile` and `XFile` with the `toMagicFile` and `toXFile` extensions.

- [Basic Usage](#basic-usage)
- [Quick Reference](#quick-reference)
- [IO Versus Web](#io-versus-web)
- [Gotchas](#gotchas)
- [Related Documentation](#related-documentation)

<a name="basic-usage"></a>
## Basic Usage

```dart
import 'package:magic/magic.dart';
import 'package:magic_picker/magic_picker.dart';

Future<void> roundTrip(XFile picked) async {
  final MagicFile file = await picked.toMagicFile();
  print('${file.name}: ${file.size} bytes');

  final xFile = await Future.value(file.toXFile());
  print(xFile.name);
}
```

The `Future.value` wrapper is what makes the sample compile on both platforms: `toXFile` is synchronous on mobile and desktop and returns a `Future` on the web. `XFile` is re-exported from this package, so `package:magic_picker/magic_picker.dart` is the only import you need for it.

<a name="quick-reference"></a>
## Quick Reference

| Member | Returns | Meaning |
|:-------|:--------|:--------|
| `XFile.toMagicFile()` | `Future<MagicFile>` | Builds a `MagicFile` from the `XFile`'s path, name, MIME type and length. Bytes load on demand. |
| `MagicFile.toXFile()` on IO | `XFile` | Wraps `path` without reading the file. Throws `UnsupportedError` when `path` is `null`. |
| `MagicFile.toXFile()` on the web | `Future<XFile>` | Reads the bytes and builds an in-memory `XFile`. Throws `UnsupportedError` when there are no bytes. |

`toMagicFile` is the same everywhere. It reads `XFile.length`, so `size` is filled without reading the content; on the web that is the blob's size.

<a name="io-versus-web"></a>
## IO Versus Web

The package picks the `toXFile` implementation at compile time: the web build gets the `Future`, every other build gets the synchronous one. Code that only ever targets mobile and desktop can call it without `await`. Code that also runs on the web has to treat the result as possibly asynchronous, as the `Future.value` wrapper above does, or branch on `kIsWeb` and write each call on its own.

A `MagicFile` built from bytes alone, such as a generated report, has no `path`, so `toXFile` throws on IO. Store the file first and convert from the stored path, or build the `XFile` yourself with `XFile.fromData`.

<a name="gotchas"></a>
## Gotchas

| Mistake | Fix |
|:--------|:----|
| Calling `file.toXFile().path` on code that also builds for the web | There it is a `Future`. `await` the result, or wrap it in `Future.value`. |
| Converting a bytes-only `MagicFile` on mobile | It has no `path` and throws `UnsupportedError`. Convert a stored or picked file instead. |
| Expecting `toMagicFile` to read the file | It only reads the length. Call `readAsBytes` when you need the content. |

<a name="related-documentation"></a>
## Related Documentation

- [Pick](./pick.md): the pickers that already return `MagicFile`.
- [Download](./download.md): `Storage.download` shares through an `XFile`.
