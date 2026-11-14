/// Conversions between [MagicFile] and the `XFile` the pickers and the share
/// sheet speak.
///
/// `toXFile` is platform-split: synchronous on IO, where it wraps the path,
/// and a `Future` on the web, where it has to read the bytes first.
library;

import 'package:image_picker/image_picker.dart' show XFile;
import 'package:magic/magic.dart' show MagicFile;

import 'mime_types.dart';

export 'magic_file_xfile_io.dart'
    if (dart.library.js_interop) 'magic_file_xfile_web.dart';

/// Builds a [MagicFile] from an `XFile` on every platform.
extension XFileToMagicFile on XFile {
  /// The size comes from [XFile.length], so a caller guarding an upload limit
  /// has a value to read; on the web it is the blob's size and nothing is
  /// read into memory to answer it. Bytes are read on demand.
  ///
  /// [XFile.mimeType] is null for every `image_picker` pick on Android and
  /// iOS, so the type falls back to the one the file name's extension implies,
  /// the same table `Pick.file` uses; it stays null for an unknown extension.
  Future<MagicFile> toMagicFile() async {
    return MagicFile(
      path: path,
      name: name,
      size: await length(),
      mimeType: mimeType ?? mimeTypeForFileName(name),
      bytesReader: readAsBytes,
    );
  }
}
