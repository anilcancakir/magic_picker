import 'package:magic/magic.dart' show LocalAdapterContract, ServiceProvider;
import 'package:share_plus/share_plus.dart';

/// Hands a share request to the platform share sheet.
typedef ShareFiles = Future<void> Function(ShareParams params);

/// Wires the picker package into Magic.
///
/// [boot] installs [LocalAdapterContract.downloadHandler], so a
/// `Storage.download` on mobile and desktop opens the share sheet. The web
/// adapter downloads through the browser and never calls the handler.
class PickerServiceProvider extends ServiceProvider {
  /// [share] replaces the platform share sheet, which a test cannot reach
  /// without a platform channel.
  PickerServiceProvider(super.app, {ShareFiles? share})
    : _share = share ?? _shareThroughSheet;

  final ShareFiles _share;

  @override
  void register() {
    //
  }

  @override
  Future<void> boot() async {
    LocalAdapterContract.downloadHandler = (String fullPath, String name) {
      // XFile ignores its `name` on IO and answers the path basename, so the
      // offered name travels as an override.
      return _share(
        ShareParams(
          files: [XFile(fullPath, name: name)],
          fileNameOverrides: [name],
        ),
      );
    };
  }

  static Future<void> _shareThroughSheet(ShareParams params) {
    return SharePlus.instance.share(params);
  }
}
