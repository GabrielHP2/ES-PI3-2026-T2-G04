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
              backgroundColor: Color(0xFFE1E1E1),
              side: BorderSide(color: Color(0xFFCACACA)),
            ),
      onPressed: onPressed,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(3),
            margin: EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          Text(data, style: TextStyle(color: Colors.black)),
        ],
      ),
    );
  }
}
