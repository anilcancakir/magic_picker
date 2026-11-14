# Installation

Add `magic_picker` to a Magic app, register its provider and check that `Pick` opens a picker.

- [Install](#install)
- [Requirements](#requirements)
- [Register the Provider](#register-the-provider)
- [Verify](#verify)
- [Related Documentation](#related-documentation)

<a name="install"></a>
## Install

```bash
flutter pub add magic_picker
dart run magic:dowel plugin:install magic_picker
```

The installer reads the package's `install.yaml` and injects `PickerServiceProvider` into the `providers` list of `lib/config/app.dart`. It publishes no config file and adds no config factory: `Pick` needs no settings.

```dart
import 'package:magic_picker/magic_picker.dart';
```

The barrel is the only import; everything under `src/` is private. It also re-exports `XFile` and `CameraDevice` from `image_picker`, because both appear in this package's signatures.

<a name="requirements"></a>
## Requirements

| Requirement | Value |
|:------------|:------|
| Dart | `>=3.13.0` |
| Flutter | `>=3.47.0` |
| Magic | `^1.0.0`, installed and bootstrapped (`lib/config/app.dart` exists) |
| Dependencies | `file_picker`, `image_picker` and `share_plus`, pulled in automatically |

<a name="register-the-provider"></a>
## Register the Provider

`plugin:install` does this for you. To do it by hand, add the provider to `lib/config/app.dart`:

```dart
import 'package:magic_picker/magic_picker.dart';

final Map<String, dynamic> appConfig = {
  'app': {
    'providers': [
      (app) => PickerServiceProvider(app),
    ],
  },
};
```

`Pick` itself is a static facade and works without the provider. The provider has one job: in `boot()` it sets `LocalAdapterContract.downloadHandler`, so `Storage.download` can open the share sheet on mobile and desktop. Without it that call throws on those platforms, see [Download](../basics/download.md).

<a name="verify"></a>
## Verify

```dart
import 'package:magic_picker/magic_picker.dart';

Future<void> main() async {
  final image = await Pick.image();
  print(image?.name ?? 'cancelled');
}
```

Run it on a device or in a browser. The system gallery opens; choosing an image prints its file name, and dismissing it prints `cancelled`. The result is a `MagicFile`, a type that lives in `package:magic/magic.dart`; import it when you name it.

<a name="related-documentation"></a>
## Related Documentation

- [Pick](../basics/pick.md): every picker and what it returns.
- [XFile Conversion](../basics/xfile.md): `toMagicFile` and `toXFile`.
- [Download](../basics/download.md): the share-sheet download handler.
- [Testing](../guides/testing.md): testing code that calls `Pick` or `Storage.download`.
