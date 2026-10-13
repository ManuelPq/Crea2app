import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Pelota con una animación sutil (flotación + giro muy leve),
/// para que no quede estática excepto cuando el partido ha terminado.
class BouncingBall extends StatefulWidget {
  const BouncingBall({
    super.key,
    this.size = 92,
    this.animate = true,
    this.asset = 'assets/images/pelota.png',
  });

  final double size;

  /// Si es false, la pelota se queda quieta (p. ej. al acabar el partido).
  final bool animate;
  final String asset;

  @override
  State<BouncingBall> createState() => _BouncingBallState();
}

class _BouncingBallState extends State<BouncingBall>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) _c.repeat();
  }

  @override
  void didUpdateWidget(covariant BouncingBall old) {
    super.didUpdateWidget(old);
    if (widget.animate && !_c.isAnimating) {
      _c.repeat();
    } else if (!widget.animate && _c.isAnimating) {
      _c.stop();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = _c.value * 2 * math.pi;
        // Flotación vertical suave (sin saltos bruscos)
        final dy = -6 * math.sin(t);
        // Giro muy leve a un lado y a otro
        final angle = 0.10 * math.sin(t);
        // "Respiración" mínima del tamaño
        final scale = 1 + 0.02 * math.sin(t);
        return Transform.translate(
          offset: Offset(0, dy),
          child: Transform.rotate(
            angle: angle,
            child: Transform.scale(scale: scale, child: child),
          ),
        );
      },
      child: Image.asset(
        widget.asset,
        width: widget.size,
        height: widget.size,
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}
