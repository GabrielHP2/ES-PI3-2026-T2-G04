import 'package:flutter/material.dart';

enum StartupState { nova, expansion, development }

class Startup {
  final String name;
  final IconData icon;
  final List<String> tags;
  final String shortDescription;
  final double contributedCapital;
  final int issuedTokens;
  final int investors_count;
  final StartupState startupState;

  Startup({
    required this.name,
    required this.icon,
    required this.tags,
    required this.shortDescription,
    required this.contributedCapital,
    required this.issuedTokens,
    required this.investors_count,
    required this.startupState,
  });
}
