import 'package:flutter/material.dart';
import 'package:frontend/classes/startup.dart';

class StartupPage extends StatefulWidget {
  final Startup startup;
  const StartupPage({required this.startup});

  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Pagina em desenvolvimento')));
  }
}
