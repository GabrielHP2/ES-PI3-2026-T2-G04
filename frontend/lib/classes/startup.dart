enum StartupState { nova, expansion, development }

class Startup {
  final String name;
  final String description;
  final double contributedCapital;
  final int issuedTokens;
  final StartupState startupState;

  Startup({
    required this.name,
    required this.description,
    required this.contributedCapital,
    required this.issuedTokens,
    required this.startupState,
  });
}
