import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Pantalla de bienvenida con la pelota animada (rebote + giro + escala).
/// Se muestra un instante al abrir la app y da paso a "Nuevo partido".
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onFinish});

  /// Se llama cuando la animación de bienvenida termina.
  final VoidCallback onFinish;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  );

  @override
  void initState() {
    super.initState();
    _c.forward();
    _c.addStatusListener((s) {
      if (s == AnimationStatus.completed) widget.onFinish();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.sunset),
        child: SafeArea(
          child: Center(
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, _) {
                final t = _c.value;
                // Rebote
                final dy = -28 * math.sin(t * math.pi * 4).abs();
                // Giro
                final rot = 0.35 * math.sin(t * math.pi * 2);
                // Escala (entrada suave)
                final scale = Curves.easeOutBack.transform(
                  (t * 2.2).clamp(0.0, 1.0),
                );
                // Aparición del texto al final
                final textOpacity = ((t - 0.55) / 0.45)
                    .clamp(0.0, 1.0)
                    .toDouble();

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.translate(
                      offset: Offset(0, dy),
                      child: Transform.rotate(
                        angle: rot,
                        child: Transform.scale(
                          scale: scale.clamp(0.6, 1.15),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/images/pelota.png',
                                width: 150,
                                height: 150,
                              ),
                              // Sombra/suelo que crece y decrece
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                width:
                                    96 +
                                    24 * (1 - math.sin(t * math.pi * 4).abs()),
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Opacity(
                      opacity: textOpacity,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Voley Score',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Marcador de vóley playa',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.95),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
