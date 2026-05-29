// João Pedro Panza Mainieri - 25006642;
import 'package:flutter/material.dart';

class FilterButton extends StatelessWidget {
  const FilterButton({
    super.key,
    required this.data,
    required this.isPressed,
    required this.onPressed,
    this.icon,
    this.iconBackgroundColor = Colors.black,
    this.backgroundColor = Colors.white,
  });

  final String data;
  final bool isPressed;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color iconBackgroundColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: !isPressed
          ? ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              side: BorderSide(color: Color(0xFFCACACA)),
            )
          : ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              side: BorderSide(color: Colors.indigo),
            ),
      onPressed: onPressed,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(3),
            margin: EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          Text(
            data,
            style: TextStyle(color: isPressed ? Colors.white : Colors.black),
          ),
        ],
      ),
    );
  }
}
