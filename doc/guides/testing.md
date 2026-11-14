# Testing

Test code that calls `Pick`, `Storage.download` and the `XFile` conversions without a device, a share sheet or a mocking library.

- [The Download Handler](#the-download-handler)
- [Resetting the Static](#resetting-the-static)
- [Faking the Pickers](#faking-the-pickers)
- [Converting Files](#converting-files)
- [Related Documentation](#related-documentation)

<a name="the-download-handler"></a>
## The Download Handler

`PickerServiceProvider` takes a `share` callback in place of the platform share sheet, which a test cannot reach without a platform channel. Boot the provider by hand and record what it is asked to share:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:magic/magic.dart';
import 'package:magic_picker/magic_picker.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  late List<ShareParams> shared;

  setUp(() {
    MagicApp.reset();
    Magic.flush();
    shared = <ShareParams>[];
  });

  tearDown(() {
    LocalAdapterContract.downloadHandler = null;
  });

  test('boot installs the download handler', () async {
    expect(LocalAdapterContract.downloadHandler, isNull);

    await PickerServiceProvider(
      Magic.app,
      share: (ShareParams params) async => shared.add(params),
    ).boot();

    await LocalAdapterContract.downloadHandler!('/tmp/a.txt', 'report.txt');

    expect(shared.single.fileNameOverrides, <String>['report.txt']);
  });
}
```

`share_plus` is a dependency of this package, so add it to your own `dev_dependencies` when a test names `ShareParams`. To go through `Storage.download`, boot Magic with the provider in `'app': {'providers': [...]}`; `Magic.init` reads `path_provider`, so mock its channel in `setUpAll`.

<a name="resetting-the-static"></a>
## Resetting the Static

`LocalAdapterContract.downloadHandler` is a static field. `MagicApp.reset()` and `Magic.flush()` do not clear it, so a handler installed by one test is still there in the next. Set it back to `null` in `tearDown`, as the sample above does.

<a name="faking-the-pickers"></a>
## Faking the Pickers

`Pick` calls the platform singletons that `image_picker` and `file_picker` publish: `ImagePickerPlatform.instance` for images, camera and video, and `FilePickerPlatform.instance` for files, directories and the save dialog. A test replaces the instance with a fake that extends the platform interface and restores the original afterwards. Depend on `image_picker_platform_interface` and `file_picker` in `dev_dependencies` to name them. The package's own `test/facades/pick_test.dart` shows complete fakes of both.

<a name="converting-files"></a>
## Converting Files

The conversions need no fake. Build a `MagicFile` by hand and convert it:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:magic/magic.dart';
import 'package:magic_picker/magic_picker.dart';

void main() {
  setUp(() {
    MagicApp.reset();
    Magic.flush();
  });

  test('a MagicFile with a path wraps into an XFile', () {
    final file = MagicFile(
      path: '/tmp/photo.jpg',
      name: 'photo.jpg',
      mimeType: 'image/jpeg',
    );

    final XFile xFile = file.toXFile();

    expect(xFile.path, '/tmp/photo.jpg');
  });
}
```

This test runs on the VM, where `toXFile` is synchronous. It would not compile for the web, where the method returns a `Future`; run web tests with `flutter test --platform chrome` and `await` the result.

<a name="related-documentation"></a>
## Related Documentation

- [Pick](../basics/pick.md): the facade under test.
- [XFile Conversion](../basics/xfile.md): the two extensions and their platform split.
- [Download](../basics/download.md): the handler `PickerServiceProvider` installs.
