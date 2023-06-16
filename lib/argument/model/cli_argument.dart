class CliArgument {
  final String name;
  final String abbr;
  final String help;
  final String? valueHelp;

  const CliArgument({
    required this.name,
    required this.abbr,
    required this.help,
    this.valueHelp,
  });

  @override
  String toString() {
    return 'CliArgument{name: $name, abbr: $abbr, help: $help, valueHelp: $valueHelp}';
  }
}
