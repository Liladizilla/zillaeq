import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: Container(
          // Add a subtle gradient and thin border so the logo is visible on dark backgrounds
            decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueGrey.shade900, Colors.blueGrey.shade800],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.blue.shade300.withAlpha((0.24 * 255).round()), width: 1.5),
          ),
          child: Center(
            child: Image.asset(
              'assets/WhatsApp Image 2025-10-17 at 2.16.33 PM.jpeg',
              fit: BoxFit.contain,
              width: size,
              height: size,
              errorBuilder: (context, error, stack) => Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.shade700,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.equalizer, color: Colors.white, size: size * 0.56),
                    SizedBox(height: 4),
                    Text('Logo', style: TextStyle(color: Colors.white70, fontSize: size * 0.12)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
