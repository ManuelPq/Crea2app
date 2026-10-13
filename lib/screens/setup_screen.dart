import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/match_record.dart';
import '../providers/scoreboard_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/bouncing_ball.dart';

/// Pantalla previa: se elige tipo de partido, puntos, cambios y nombres.
class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key, this.onStart});

  /// Se llama al pulsar "Empezar" (para cerrar el flujo desde fuera).
  final VoidCallback? onStart;

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
    final s = _setup.copyWith(
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
          child: Row(
            children: [
              // Columna izquierda: pelota + título (centrado)
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BouncingBall(size: 150),
                      const SizedBox(height: 22),
                      const Text(
                        'Nuevo partido',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 0.95,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Configura el partido antes de empezar 🏐',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.white.withValues(alpha: 0.92),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Columna derecha: configuración (centrada)
              Expanded(
                flex: 6,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(0, 14, 14, 14),
                  padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
                  decoration: BoxDecoration(
                    color: dark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _label('Equipos'),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _a,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 20, fontWeight: FontWeight.w700),
                                  decoration: InputDecoration(
                                    labelText: 'Equipo A',
                                    labelStyle: const TextStyle(fontSize: 15),
                                    hintText: 'Equipo A',
                                    border: const OutlineInputBorder(),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 18),
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 14),
                                child: Text('VS',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900)),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _b,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 20, fontWeight: FontWeight.w700),
                                  decoration: InputDecoration(
                                    labelText: 'Equipo B',
                                    labelStyle: const TextStyle(fontSize: 15),
                                    hintText: 'Equipo B',
                                    border: const OutlineInputBorder(),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 18),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          _label('Tipo de partido'),
                          SegmentedButton<MatchType>(
                            segments: const [
                              ButtonSegment(
                                value: MatchType.single,
                                label: Text('Único'),
                                icon: Icon(Icons.looks_one),
                              ),
                              ButtonSegment(
                                value: MatchType.bestOf3,
                                label: Text('Mejor de 3'),
                                icon: Icon(Icons.filter_3),
                              ),
                            ],
                            selected: {_setup.type},
                            onSelectionChanged: (v) => setState(
                                () => _setup = _setup.copyWith(type: v.first)),
                          ),
                          if (_setup.type == MatchType.bestOf3) ...[
                            const SizedBox(height: 16),
                            _numRow(
                              'Puntos del set decisivo',
                              _setup.decidingPoints,
                              5,
                              21,
                              (v) => setState(() =>
                                  _setup = _setup.copyWith(decidingPoints: v)),
                            ),
                          ],
                          const SizedBox(height: 20),
                          // Números grandes en fila (centrados)
                          Row(
                            children: [
                              Expanded(
                                child: _numRow(
                                  'Puntos para finalizar',
                                  _setup.targetPoints,
                                  5,
                                  30,
                                  (v) => setState(() => _setup =
                                      _setup.copyWith(targetPoints: v)),
                                  big: true,
                                  center: true,
                                ),
                              ),
                              Container(
                                  width: 1,
                                  height: 70,
                                  color: Theme.of(context).dividerColor),
                              Expanded(
                                child: _numRow(
                                  'Cambio de pista cada',
                                  _setup.switchEvery,
                                  0,
                                  15,
                                  (v) => setState(() => _setup =
                                      _setup.copyWith(switchEvery: v)),
                                  big: true,
                                  center: true,
                                  suffix: _setup.switchEvery == 0
                                      ? 'sin cambios'
                                      : 'puntos',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.sunsetDeep,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                              ),
                              onPressed: _start,
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('EMPEZAR',
                                  style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(t.toUpperCase(),
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                color: AppColors.sunsetDeep)),
      );

  Widget _numRow(
    String title,
    int value,
    int min,
    int max,
    ValueChanged<int> onChanged, {
    bool big = false,
    String suffix = 'puntos',
    bool center = false,
  }) {
    return Column(
      crossAxisAlignment:
          center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        _label(title),
        Row(
          mainAxisSize: center ? MainAxisSize.min : MainAxisSize.max,
          mainAxisAlignment:
              center ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            _circleBtn(
                Icons.remove, value > min ? () => onChanged(value - 1) : null),
            Container(
              constraints: const BoxConstraints(minWidth: 74),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Text(
                    '$value',
                    style: TextStyle(
                      fontSize: big ? 44 : 30,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  if (suffix.isNotEmpty)
                    Text(suffix,
                        style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color)),
                ],
              ),
            ),
            _circleBtn(
                Icons.add, value < max ? () => onChanged(value + 1) : null),
          ],
        ),
      ],
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback? onTap) {
    return IconButton.filledTonal(
      onPressed: onTap,
      iconSize: 24,
      icon: Icon(icon),
    );
  }
}
