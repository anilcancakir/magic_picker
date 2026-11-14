import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
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
  late _RecordingFilePicker filePicker;
  late FilePickerPlatform originalFilePicker;

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
    originalFilePicker = FilePickerPlatform.instance;
    filePicker = _RecordingFilePicker();
    FilePickerPlatform.instance = filePicker;
    documentsDir = Directory.systemTemp.createTempSync('magic_picker_share_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          _pathProviderChannel,
          (MethodCall call) async => documentsDir.path,
        );
  });

  tearDown(() {
    LocalAdapterContract.downloadHandler = null;
    debugDefaultTargetPlatformOverride = null;
    FilePickerPlatform.instance = originalFilePicker;
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

    for (final TargetPlatform platform in <TargetPlatform>[
      TargetPlatform.android,
      TargetPlatform.iOS,
      TargetPlatform.macOS,
      TargetPlatform.windows,
    ]) {
      test('a download on $platform opens the share sheet', () async {
        debugDefaultTargetPlatformOverride = platform;
        await bootWithRecordingShare();
        final disk = LocalDisk(root: 'storage');
        await disk.put('reports/a.txt', 'payload');

        await disk.download('reports/a.txt', name: 'report.txt');

        expect(shared, hasLength(1));
        expect(filePicker.saved, isEmpty);
      });
    }

    test(
      'a download on Linux opens the save dialog with the file bytes',
      () async {
        // share_plus throws UnimplementedError for any file on Linux, so the
        // share sheet is never offered there.
        debugDefaultTargetPlatformOverride = TargetPlatform.linux;
        await bootWithRecordingShare();
        final disk = LocalDisk(root: 'storage');
        await disk.put('reports/a.txt', 'payload');

        await disk.download('reports/a.txt', name: 'report.txt');

        expect(shared, isEmpty);
        final _SavedFile saved = filePicker.saved.single;
        expect(saved.fileName, 'report.txt');
        expect(saved.bytes, Uint8List.fromList('payload'.codeUnits));
        expect(saved.mimeType, 'text/plain');
      },
    );

    test(
      'a Linux download without a name is saved under the basename',
      () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.linux;
        await bootWithRecordingShare();
        final disk = LocalDisk(root: 'storage');
        await disk.put('reports/a.txt', 'payload');

        await disk.download('reports/a.txt');

        expect(filePicker.saved.single.fileName, 'a.txt');
      },
    );

    test('a cancelled Linux save dialog completes without an error', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      await bootWithRecordingShare();
      final disk = LocalDisk(root: 'storage');
      await disk.put('reports/a.txt', 'payload');
      filePicker.cancel = true;

      await disk.download('reports/a.txt');

      expect(filePicker.saved, hasLength(1));
      expect(shared, isEmpty);
    });
  });
}

class _SavedFile {
  _SavedFile(this.fileName, this.bytes, this.mimeType);

  final String fileName;
  final Uint8List bytes;
  final String mimeType;
}

/// Records what reaches the save dialog; every other picker is unused here.
class _RecordingFilePicker extends FilePickerPlatform {
  final List<_SavedFile> saved = <_SavedFile>[];

  /// Answers `null` from the dialog, as a user who closes it does.
  bool cancel = false;

  @override
  Future<Uri?> saveFile({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
    String? dialogTitle,
    String? initialDirectory,
    Function(FilePickerStatus)? onFileSaving,
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async {
    saved.add(_SavedFile(fileName, bytes, mimeType));

    return cancel ? null : Uri.file('/tmp/$fileName');
  }
}
