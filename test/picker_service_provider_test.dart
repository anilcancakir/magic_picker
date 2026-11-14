import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magic/magic.dart'
    show LocalAdapterContract, LocalDisk, Magic, MagicApp;
import 'package:magic_picker/magic_picker.dart';
import 'package:share_plus/share_plus.dart' show ShareParams;

const MethodChannel _pathProviderChannel = MethodChannel(
  'plugins.flutter.io/path_provider',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory documentsDir;
  late List<ShareParams> shared;

  Future<void> bootWithRecordingShare() {
    return Magic.init(
      configs: [
        {
          'app': {
            'providers': [
              (app) => PickerServiceProvider(
                app,
                share: (ShareParams params) async => shared.add(params),
              ),
            ],
          },
        },
      ],
    );
  }

  setUp(() {
    MagicApp.reset();
    Magic.flush();
    shared = <ShareParams>[];
    documentsDir = Directory.systemTemp.createTempSync('magic_picker_share_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          _pathProviderChannel,
          (MethodCall call) async => documentsDir.path,
        );
  });

  tearDown(() {
    LocalAdapterContract.downloadHandler = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_pathProviderChannel, null);
    if (documentsDir.existsSync()) {
      documentsDir.deleteSync(recursive: true);
    }
  });

  group('PickerServiceProvider', () {
    test('boot installs the storage download handler', () async {
      expect(LocalAdapterContract.downloadHandler, isNull);

      await bootWithRecordingShare();

      expect(LocalAdapterContract.downloadHandler, isNotNull);
    });

    test(
      'a local download reaches the share seam with the file name',
      () async {
        await bootWithRecordingShare();
        final disk = LocalDisk(root: 'storage');
        final String fullPath = await disk.put('reports/a.txt', 'payload');

        await disk.download('reports/a.txt', name: 'report.txt');

        final ShareParams params = shared.single;
        expect(params.files!.single.path, fullPath);
        expect(params.fileNameOverrides, <String>['report.txt']);
      },
    );

    test('a download without a name is offered under the basename', () async {
      await bootWithRecordingShare();
      final disk = LocalDisk(root: 'storage');
      await disk.put('reports/a.txt', 'payload');

      await disk.download('reports/a.txt');

      expect(shared.single.fileNameOverrides, <String>['a.txt']);
    });
  });
}
