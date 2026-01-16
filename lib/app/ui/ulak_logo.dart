import 'package:flutter/material.dart';

class UlakLogo extends StatelessWidget {
  const UlakLogo({super.key, this.size = 28});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.28),
      child: Image.asset(
        'assets/logo.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Icon(Icons.shield, size: size),
      ),
    );
  }
}
