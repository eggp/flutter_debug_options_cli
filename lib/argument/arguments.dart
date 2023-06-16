import 'dart:io';

import 'package:args/args.dart';
import 'package:collection/collection.dart';

import '../util/pens.dart';
import 'model/cli_argument.dart';

class Arguments {
  final List<CliArgument> _cliArguments;
  late final ArgParser _parser;
  late final ArgResults _args;

  String get cliUsage => _parser.usage;

  Arguments({
    required List<CliArgument> cliArguments,
    required List<String> userArguments,
  }) : _cliArguments = cliArguments {
    _parseArgs(userArguments);
  }

  void _buildParser() {
    _parser = ArgParser();
    _cliArguments.forEach((cliArgument) {
      if (cliArgument.valueHelp != null) {
        _parser.addOption(
          cliArgument.name,
          abbr: cliArgument.abbr,
          help: cliArgument.help,
          valueHelp: cliArgument.valueHelp,
        );
      } else {
        _parser.addFlag(
          cliArgument.name,
          abbr: cliArgument.abbr,
          negatable: false,
          help: cliArgument.help,
        );
      }
    });
  }

  void _parseArgs(List<String> arguments) {
    _buildParser();

    try {
      _args = _parser.parse(arguments);
    } catch (_) {
      print(ansiPenRed(_parser.usage));
      exit(1);
    }
  }

  T getParsedArg<T>({
    String? name,
    CliArgument? cliArgument,
    bool checkNull = true,
  }) {
    assert((name != null && cliArgument == null) || (name == null && cliArgument != null));
    final searchOptionName = name ?? cliArgument!.name;
    final foundOptionName = _args.options.firstWhereOrNull((option) => option == searchOptionName);

    if (foundOptionName == null) {
      if (checkNull) {
        throw 'Not found user argument: $name';
      }
    }

    return _args[foundOptionName ?? searchOptionName];
  }
}
