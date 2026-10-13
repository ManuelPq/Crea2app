import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Fuerza el uso en horizontal: si el dispositivo está en vertical,
/// muestra un aviso pidiendo girar el móvil (en vez de romper el diseño).
class OrientationGate extends StatelessWidget {
  const OrientationGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.orientationOf(context) == Orientation.portrait;
    if (!isPortrait) return child;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.sunset),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _RotatingIcon(),
                const SizedBox(height: 28),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Gira el móvil',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Voley Score está pensado para jugarse en horizontal, '
                    'a pie de pista 🏐',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontSize: 16,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Icono de móvil que se gira solo, invitando a rotar.
class _RotatingIcon extends StatefulWidget {
  @override
  State<_RotatingIcon> createState() => _RotatingIconState();
}

class _RotatingIconState extends State<_RotatingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final angle = math.pi / 2 * Curves.easeInOut.transform(_c.value);
        return Transform.rotate(
          angle: -angle,
          child: Container(
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(Icons.phone_android,
                size: 84, color: Colors.white),
          ),
        );
      },
    );
  }
}
