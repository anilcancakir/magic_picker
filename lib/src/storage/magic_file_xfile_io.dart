import 'package:image_picker/image_picker.dart' show XFile;
import 'package:magic/magic.dart' show MagicFile;

/// Converts a [MagicFile] to an `XFile` on mobile and desktop.
extension MagicFileToXFile on MagicFile {
  /// Wraps [MagicFile.path] without reading the file.
  ///
  /// Throws [UnsupportedError] when the file has no path, as one built from
  /// bytes alone does.
  XFile toXFile() {
    if (path == null) {
      throw UnsupportedError(
        'Cannot convert to XFile: path is null. '
        'This MagicFile may have been created from bytes only.',
      );
    }

    return XFile(path!, name: name, mimeType: mimeType);
  }
}
