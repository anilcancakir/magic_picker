import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:magic/magic.dart' show Magic, MagicApp, MagicFile;
import 'package:magic_picker/magic_picker.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    MagicApp.reset();
    Magic.flush();
    tempDir = await Directory.systemTemp.createTemp('magic_picker_xfile_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('MagicFile.toXFile', () {
    test('returns an XFile when path is set', () {
      final magicFile = MagicFile(
        path: '/test/path/image.jpg',
        name: 'image.jpg',
        mimeType: 'image/jpeg',
      );

      final XFile xFile = magicFile.toXFile();

      expect(xFile.path, '/test/path/image.jpg');
      expect(xFile.name, 'image.jpg');
      expect(xFile.mimeType, 'image/jpeg');
    });

    test('throws when path is null', () {
      final magicFile = MagicFile(
        name: 'image.jpg',
        bytes: Uint8List.fromList([1, 2, 3]),
      );

      expect(() => magicFile.toXFile(), throwsUnsupportedError);
    });
  });

  group('XFile.toMagicFile', () {
    late File testFile;

    setUp(() async {
      testFile = File('${tempDir.path}/test_image.jpg');
      await testFile.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0]);
    });

    test('creates a MagicFile from an XFile', () async {
      final xFile = XFile(testFile.path, name: 'xfile_test.jpg');

      final magicFile = await xFile.toMagicFile();

      expect(magicFile.path, testFile.path);
      // XFile.name answers the file basename on IO, not the custom name.
      expect(magicFile.name, 'test_image.jpg');
      expect(magicFile.size, 4);
    });

    test('reads the bytes through the XFile', () async {
      final magicFile = await XFile(testFile.path).toMagicFile();

      final bytes = await magicFile.readAsBytes();

      expect(bytes, isNotNull);
      expect(bytes!.length, 4);
    });

    test('carries the size and mime type of an in-memory XFile', () async {
      final xFile = XFile.fromData(
        Uint8List(600),
        name: 'logo.png',
        mimeType: 'image/png',
      );

      final magicFile = await xFile.toMagicFile();

      expect(magicFile.size, 600);
      expect(magicFile.mimeType, 'image/png');
    });
  });

  test('round-trip: XFile -> MagicFile -> XFile', () async {
    final originalFile = File('${tempDir.path}/original.jpg');
    await originalFile.writeAsBytes([1, 2, 3, 4, 5]);

    final xFile = XFile(originalFile.path, mimeType: 'image/jpeg');
    final magicFile = await xFile.toMagicFile();
    final recoveredXFile = magicFile.toXFile();

    expect(recoveredXFile.path, originalFile.path);
    expect(recoveredXFile.name, 'original.jpg');
    expect(await recoveredXFile.readAsBytes(), [1, 2, 3, 4, 5]);
  });
}
