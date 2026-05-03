import 'package:flutter/material.dart';

class StartupInfoContainer extends StatelessWidget {
  final String? infoText;
  final String? subText;
  const StartupInfoContainer({
    super.key,
    required this.infoText,
    required this.subText,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300, width: 1),
        borderRadius: BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 1),
        ],
      ),
      width: 100,
      height: 100,
      child: Column(
        crossAxisAlignment: .center,
        mainAxisAlignment: .center,
        children: [
          Text(
            '$infoText',
            style: TextStyle(
              color: Colors.black,
              fontWeight: .bold,
              fontSize: 16,
            ),
          ),
          Text(
            '$subText',
            style: TextStyle(
              color: Colors.black,
              fontWeight: .w300,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
