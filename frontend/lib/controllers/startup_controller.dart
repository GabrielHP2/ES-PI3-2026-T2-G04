import 'package:flutter/material.dart';
import 'package:frontend/models/startup.dart';

IconData getStartupStateIcon(Startup startup) {
  if (startup.estagio == StartupStage.nova) {
    return Icons.lightbulb;
  } else if (startup.estagio == StartupStage.expansao) {
    return Icons.public;
  } else {
    return Icons.science;
  }
}

Color getStartupStateColor(Startup startup) {
  if (startup.estagio == StartupStage.nova) {
    return const Color(0xff7AE058);
  } else if (startup.estagio == StartupStage.expansao) {
    return Colors.indigo;
  } else {
    return Colors.deepOrangeAccent;
  }
}
