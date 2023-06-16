import 'dart:io';

import 'package:dart_emoji/dart_emoji.dart';
import 'package:pub_update_checker/pub_update_checker.dart';

import 'argument/arguments.dart';
import 'common/cli_arguments.dart';
import 'util/pens.dart';

class FlutterDebugOptionsCli {
  late final String _globalFlutterDirectoryPath;
  late final Arguments _userArguments;

  FlutterDebugOptionsCli._();

  static Future<void> run(List<String> arguments) async {
    final cli = FlutterDebugOptionsCli._();
    // Prepare
    await cli._checkNewVersion();
    cli._parseArgs(arguments);
    // Work
    await cli._run();
  }

  Future<void> _checkNewVersion() async {
    final newVersion = await PubUpdateChecker.check();
    if (newVersion != null) {
      print(
        ansiPenCyan(
          'There is an update available: $newVersion.\nPlease run `dart pub global activate flutter_debug_options_cli` to update.',
        ),
      );
    }
  }

  Future<void> _buildGlobalFlutterDirectoryPath() async {
    final maybeFlutterBinPath = _userArguments.getParsedArg(
      cliArgument: cliArgumentFlutterBinPath,
      checkNull: false,
    );
    if (maybeFlutterBinPath != null) {
      _globalFlutterDirectoryPath = maybeFlutterBinPath;
    } else {
      final String flutterBinPath;
      if (Platform.isWindows) {
        final whereFlutterBin = await Process.run('where', ['flutter']);
        flutterBinPath = (whereFlutterBin.stdout as String).split('\n').first;
      } else {
        // macOS and Linux
        final whichFlutterBin = await Process.run('which', ['flutter']);
        flutterBinPath = whichFlutterBin.stdout as String;
      }

      final resolvedFlutterPath = File(flutterBinPath.trim()).resolveSymbolicLinksSync();
      _globalFlutterDirectoryPath = File(resolvedFlutterPath).parent.parent.path;
    }
  }

  File _getChromeDartFile() {
    return File('$_globalFlutterDirectoryPath/packages/flutter_tools/lib/src/web/chrome.dart');
  }

  void _activate({
    required File chromeDartFile,
    required String chromeDartFileContent,
  }) {
    if (_isEnabledExtensionsInChrome(chromeDartFileContent)) {
      print(
        ansiPenRed('The extensions are already turned on!'),
      );
      exit(1);
    }

    final newContent = chromeDartFileContent.replaceFirst(
      chromeParameterDisableExtension,
      '',
    );

    _updateChromeDartFile(chromeDartFile: chromeDartFile, newContent: newContent);

    final parser = EmojiParser();
    print(parser.emojify(List.generate(20, (index) => ':tada:').join()));
    print(
      parser.emojify(
        ':sun_with_face::sun_with_face: ${ansiPenGreen('You can now use the extensions')} :sun_with_face::sun_with_face:',
      ),
    );
    print(parser.emojify(List.generate(20, (index) => ':tada:').join()));
    print(
      '\n${ansiPenRed('!WARNING!')} Please run ${ansiPenCyan('flutter doctor')} command.\nThis is necessary for flutter to gather itself :) It may take a little longer, but only the first time!',
    );
  }

  void _updateChromeDartFile({
    required File chromeDartFile,
    required String newContent,
  }) {
    _deleteFlutterToolsStampFile();

    print(ansiPenCyan('Updating ${chromeDartFile.path}\n'));
    chromeDartFile.writeAsStringSync(newContent);
  }

  void _deleteFlutterToolsStampFile() {
    final flutterToolsStampFile = File('$_globalFlutterDirectoryPath/bin/cache/flutter_tools.stamp');
    if (flutterToolsStampFile.existsSync()) {
      print(
        ansiPenCyan(
          'Deleting ${flutterToolsStampFile.path}, this change is necessary for Flutter to detect the changes',
        ),
      );
      flutterToolsStampFile.deleteSync();
    }
  }

  bool _isEnabledExtensionsInChrome(String chromeDartFileContent) =>
      !chromeDartFileContent.contains(chromeParameterDisableExtension);

  void _status({
    required String chromeDartFileContent,
  }) {
    print(
      _isEnabledExtensionsInChrome(chromeDartFileContent)
          ? ansiPenGreen('Flutter enable extensions to chrome')
          : ansiPenRed('Flutter disable extensions to chrome'),
    );
  }

  void _reset({
    required File chromeDartFile,
    required String chromeDartFileContent,
  }) {
    if (!_isEnabledExtensionsInChrome(chromeDartFileContent)) {
      print(
        ansiPenRed('The extensions are already turned off!'),
      );
      exit(1);
    }

    const chromeLaunchText = '      // Chrome launch.\n';
    final newContent = chromeDartFileContent.replaceFirst(
      chromeLaunchText,
      '$chromeLaunchText$chromeParameterDisableExtension',
    );

    _updateChromeDartFile(chromeDartFile: chromeDartFile, newContent: newContent);

    final parser = EmojiParser();
    print(ansiPenGreen('Reset flutter chrome settings(disable extensions)'));
  }

  Future<void> _run() async {
    final activate = _userArguments.getParsedArg<bool>(cliArgument: cliArgumentActivate);
    final status = _userArguments.getParsedArg<bool>(cliArgument: cliArgumentStatus);
    final reset = _userArguments.getParsedArg<bool>(cliArgument: cliArgumentReset);
    if (activate == false && status == false && reset == false) {
      return print(ansiPenRed('Usage:\n${_userArguments.cliUsage}'));
    }

    await _buildGlobalFlutterDirectoryPath();

    final chromeDartFile = _getChromeDartFile();
    final chromeDartFileContent = chromeDartFile.readAsStringSync();

    if (_userArguments.getParsedArg(cliArgument: cliArgumentActivate)) {
      _activate(
        chromeDartFile: chromeDartFile,
        chromeDartFileContent: chromeDartFileContent,
      );
    } else if (_userArguments.getParsedArg(cliArgument: cliArgumentStatus)) {
      _status(
        chromeDartFileContent: chromeDartFileContent,
      );
    } else if (_userArguments.getParsedArg(cliArgument: cliArgumentReset)) {
      _reset(
        chromeDartFile: chromeDartFile,
        chromeDartFileContent: chromeDartFileContent,
      );
    }
  }

  void _parseArgs(List<String> arguments) {
    _userArguments = Arguments(
      cliArguments: cliArguments,
      userArguments: arguments,
    );
  }
}
