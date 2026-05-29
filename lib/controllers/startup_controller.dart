// João Pedro Panza Mainieri - 25006642;
import 'package:flutter/material.dart';
import 'package:frontend/models/startup.dart';

IconData getStartupStateIcon(StartupStage startupStage) {
  if (startupStage == StartupStage.nova) {
    return Icons.lightbulb;
  } else if (startupStage == StartupStage.expansao) {
    return Icons.public;
  } else {
    return Icons.science;
  }
}

Color getStartupStateColor(StartupStage startupStage) {
  if (startupStage == StartupStage.nova) {
    return const Color(0xff7AE058);
  } else if (startupStage == StartupStage.expansao) {
    return Colors.indigo;
  } else {
    return Colors.deepOrangeAccent;
  }
}
