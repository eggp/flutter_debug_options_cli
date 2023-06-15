import 'package:flutter_debug_options_cli/flutter_debug_options_cli.dart' as flutter_debug_options_cli;

// void main(List<String> arguments) {
//   print('Hello world: ${flutter_debug_options_cli.calculate()}!');
// }

/// Based on https://stackoverflow.com/a/66879350/8174191
void main(List<String> arguments) async {
  final newVersion = await PubUpdateChecker.check();
  if (newVersion != null) {
    print(
      yellowPen(
        'There is an update available: $newVersion. Run `dart pub global activate flutter_cors` to update.',
      ),
    );
  }

  final ArgResults args;
  try {
    args = parser.parse(arguments);
  } catch (_) {
    print(magentaPen(parser.usage));
    exit(1);
  }
  final flutterFolderPath = await getFlutterFolderPath(args);

  if (args[flagEnable]) {
    enable(flutterFolderPath, args);
  } else if (args[flagDisable]) {
    disable(flutterFolderPath, args);
  } else {
    print(magentaPen(parser.usage));
  }

  exit(0);
}