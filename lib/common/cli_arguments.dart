import '../argument/model/cli_argument.dart';

const cliArgumentActivate =
    CliArgument(name: 'activate', abbr: 'a', help: 'Activate this plugin(enable extensions in chrome)');
const cliArgumentStatus =
    CliArgument(name: 'status', abbr: 's', help: 'Show chrome extension enabled or disabled status');
const cliArgumentReset =
    CliArgument(name: 'reset', abbr: 'r', help: 'Reset to original state(disable extensions in chrome)');
const cliArgumentFlutterBinPath = CliArgument(
  name: 'global-flutter-directory-path',
  abbr: 'p',
  help: 'Global Flutter path (determined automatically if not specified)',
  valueHelp: 'path',
);

const chromeParameterDisableExtension = "      '--disable-extensions',\n";

final List<CliArgument> cliArguments = [
  cliArgumentActivate,
  cliArgumentStatus,
  cliArgumentReset,
  cliArgumentFlutterBinPath,
];
