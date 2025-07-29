import 'package:flutter/material.dart';

class ChastityLogo extends StatelessWidget {
  final double size;
  final Color color;

  const ChastityLogo({super.key, this.size = 100.0, this.color = Colors.indigo});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Center(
        child: Text(
          'C',
          style: TextStyle(
            color: color,
            fontSize: size * 0.6,
            fontWeight: FontWeight.bold,
            fontFamily: 'Times New Roman',
          ),
        ),
      ),
    );
  }
}
