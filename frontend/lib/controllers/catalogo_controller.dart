import 'package:flutter/material.dart';
import 'package:frontend/classes/startup.dart';

IconData getStartupStateIcon(Startup startup) {
  if (startup.startupState == StartupState.nova) {
    return Icons.lightbulb;
  } else if (startup.startupState == StartupState.expansion) {
    return Icons.public;
  } else {
    return Icons.science;
  }
}
