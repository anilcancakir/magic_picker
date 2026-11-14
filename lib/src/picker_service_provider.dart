import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:magic/magic.dart' show LocalAdapterContract, ServiceProvider;
import 'package:share_plus/share_plus.dart';

import 'facades/pick.dart';

/// Hands a share request to the platform share sheet.
typedef ShareFiles = Future<void> Function(ShareParams params);

/// Wires the picker package into Magic.
///
/// [boot] installs [LocalAdapterContract.downloadHandler], so a
/// `Storage.download` on mobile and desktop offers the file to the user. The
/// share sheet carries it everywhere except Linux, where `share_plus` throws
/// for any file, so there the handler opens the save dialog with the file's
/// bytes instead. The web adapter downloads through the browser and never
/// calls the handler.
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
      if (defaultTargetPlatform == TargetPlatform.linux) {
        return _saveThroughDialog(fullPath, name);
      }

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

  /// `share_plus` has no file sharing on Linux, so the user picks where the
  /// file goes. Closing the dialog is a cancelled download, not an error.
  static Future<void> _saveThroughDialog(String fullPath, String name) async {
    await Pick.saveFile(
      fileName: name,
      bytes: await XFile(fullPath).readAsBytes(),
    );
  }

  static Future<void> _shareThroughSheet(ShareParams params) {
    return SharePlus.instance.share(params);
  }
}
