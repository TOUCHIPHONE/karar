import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {
  const AuthBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF283593),
            Color(0xFF1A237E),
          ],
        ),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Icon(
                Icons.factory,
                color: Colors.white.withOpacity(0.25),
                size: 96,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
