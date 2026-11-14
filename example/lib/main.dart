import 'package:flutter/widgets.dart';
import 'package:magic/magic.dart';
import 'package:magic_picker/magic_picker.dart';

const Color _ink = Color(0xFF111827);
const Color _accent = Color(0xFF4F46E5);
const TextStyle _text = TextStyle(color: _ink, fontSize: 16);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Magic.init(
    configs: [
      {
        'app': {
          'providers': [(app) => PickerServiceProvider(app)],
        },
      },
    ],
  );

  runApp(const ExampleApp());
}

/// One button that opens the gallery and describes what came back.
class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      title: 'magic_picker example',
      color: _accent,
      textStyle: _text,
      pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) {
        return PageRouteBuilder<T>(
          settings: settings,
          pageBuilder: (context, _, _) => builder(context),
        );
      },
      home: const PickPage(),
    );
  }
}

class PickPage extends StatefulWidget {
  const PickPage({super.key});

  @override
  State<PickPage> createState() => _PickPageState();
}

class _PickPageState extends State<PickPage> {
  String _output = 'Nothing picked yet.';

  Future<void> _pick() async {
    final MagicFile? image = await Pick.image(maxWidth: 1024);

    // A null result is a cancelled pick, not an error.
    final String message = image == null
        ? 'Cancelled.'
        : '${image.name}\n${image.size} bytes\n${image.mimeType}';

    if (!mounted) return;
    setState(() => _output = message);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [_Button(label: 'Pick an image', onTap: _pick)],
            ),
            const SizedBox(height: 16),
            Text(_output, style: _text),
          ],
        ),
      ),
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: _accent,
        child: Text(label, style: const TextStyle(color: Color(0xFFFFFFFF))),
      ),
    );
  }
}
