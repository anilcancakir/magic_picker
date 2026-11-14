import 'package:image_picker/image_picker.dart' show XFile;
import 'package:magic/magic.dart' show MagicFile;

/// Converts a [MagicFile] to an `XFile` in the browser.
extension MagicFileToXFile on MagicFile {
  /// Builds an in-memory `XFile` from the file's bytes, since the web has no
  /// file system path to wrap.
  ///
  /// Throws [UnsupportedError] when the file has no bytes to read.
  Future<XFile> toXFile() async {
    final bytes = await readAsBytes();
    if (bytes == null) {
      throw UnsupportedError('Cannot convert to XFile: no bytes available.');
    }

    return XFile.fromData(bytes, name: name, mimeType: mimeType);
  }
}
