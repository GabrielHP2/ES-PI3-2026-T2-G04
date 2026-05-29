// João Pedro Panza Mainieri - 25006642;
import 'package:flutter/material.dart';

class StartupTag extends StatelessWidget {
  final String label;
  const StartupTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.indigo, width: 1),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF4A51E0),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
