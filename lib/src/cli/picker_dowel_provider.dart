import 'package:dowel/dowel.dart';

/// The dowel provider for Magic Picker.
///
/// Contributes no commands. It exists because dowel `plugin:install` resolves
/// a plugin through `package:magic_picker/cli.dart` and registers the class
/// named `<PascalCase package>DowelProvider` from it.
class MagicPickerDowelProvider extends DowelServiceProvider {
  @override
  String get providerName => 'magic_picker';

  @override
  List<DowelCommand> commands() => <DowelCommand>[];
}
