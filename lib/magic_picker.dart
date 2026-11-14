/// File and image picking for Magic apps.
///
/// `Pick` opens the system pickers and answers with a `MagicFile`;
/// [PickerServiceProvider] routes `Storage.download` to the share sheet on
/// mobile, macOS and Windows and to the save dialog on Linux. `CameraDevice`
/// and `XFile` are exported because they appear in this package's own
/// signatures.
library;

export 'package:image_picker/image_picker.dart' show CameraDevice, XFile;

export 'src/facades/pick.dart';
export 'src/picker_service_provider.dart';
export 'src/storage/magic_file_xfile.dart';
