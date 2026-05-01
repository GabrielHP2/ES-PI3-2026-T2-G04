import 'package:flutter/material.dart';
import 'package:frontend/models/startup.dart';

IconData getStartupStateIcon(Startup startup) {
  if (startup.startupState == StartupState.nova) {
    return Icons.lightbulb;
  } else if (startup.startupState == StartupState.expansion) {
    return Icons.public;
  } else {
    return Icons.science;
  }
}

Color getStartupStateColor(Startup startup) {
  if (startup.startupState == StartupState.nova) {
    return const Color(0xff7AE058);
  } else if (startup.startupState == StartupState.expansion) {
    return Colors.indigo;
  } else {
    return Colors.deepOrangeAccent;
  }
}
