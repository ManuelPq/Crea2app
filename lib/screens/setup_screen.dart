import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/match_record.dart';
import '../providers/scoreboard_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/bouncing_ball.dart';

/// Pantalla previa al partido, deliberadamente sencilla:
/// solo los nombres de los equipos + EMPEZAR.
/// Los puntos y el cambio de pista se toman de los Ajustes.
class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key, this.onStart, this.onOpenSettings});

  final VoidCallback? onStart;
  final VoidCallback? onOpenSettings;

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  late GameSetup _setup;
  late TextEditingController _a;
  late TextEditingController _b;

  @override
  void initState() {
    super.initState();
    final score = context.read<ScoreboardProvider>();
    _setup = score.settings.defaultSetup;
    _a = TextEditingController(text: _setup.teamA);
    _b = TextEditingController(text: _setup.teamB);
  }

  @override
  void dispose() {
    _a.dispose();
    _b.dispose();
    super.dispose();
  }

  void _start() {
    final score = context.read<ScoreboardProvider>();
    // Toma la configuración actual de los Ajustes.
    final base = score.settings.defaultSetup;
    final s = base.copyWith(
      teamA: _a.text.trim().isEmpty ? 'Equipo A' : _a.text.trim(),
      teamB: _b.text.trim().isEmpty ? 'Equipo B' : _b.text.trim(),
    );
    score.startMatch(s);
    widget.onStart?.call();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: dark
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.darkBg, Color(0xFF1E2A38)],
                )
              : AppGradients.sunset,
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, c) {
              final h = c.maxHeight;
              final compacto = h < 340;
              return Padding(
                padding: EdgeInsets.all(compacto ? 10 : 14),
                child: Row(
                  children: [
                    Expanded(
                      flex: 32,
                      child: _columnaIzquierda(compacto: compacto),
                    ),
                    SizedBox(width: compacto ? 8 : 14),
                    Expanded(
                      flex: 68,
                      child: _tarjeta(compacto: compacto, dark: dark),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _columnaIzquierda({required bool compacto}) {
    final ballSize = compacto ? 92.0 : 140.0;
    final titleSize = compacto ? 28.0 : 40.0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        BouncingBall(size: ballSize),
        SizedBox(height: compacto ? 6 : 14),
        Text(
          'Nuevo partido',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: titleSize,
            height: 1,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        if (!compacto) ...[
          const SizedBox(height: 8),
          Text(
            'Pon el nombre a cada equipo\ny pulsa EMPEZAR',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.3,
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
        ],
      ],
    );
  }

  Widget _tarjeta({required bool compacto, required bool dark}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compacto ? 20 : 30,
        vertical: compacto ? 12 : 18,
      ),
      decoration: BoxDecoration(
        color: dark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _teamField(_a, 'Equipo A'),
          SizedBox(height: compacto ? 12 : 18),
          _teamField(_b, 'Equipo B'),
          SizedBox(height: compacto ? 12 : 20),
          // Botón EMPEZAR (en naranja) en el espacio que antes ocupaba el
          // resumen de ajustes.
          SizedBox(
            height: compacto ? 50 : 60,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.sunsetDeep,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _start,
              icon: const Icon(Icons.play_arrow, size: 26),
              label: const Text(
                'EMPEZAR',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _teamField(TextEditingController c, String label) {
    return TextField(
      controller: c,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 15),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
