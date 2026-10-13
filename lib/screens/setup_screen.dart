import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/match_record.dart';
import '../providers/scoreboard_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/bouncing_ball.dart';

/// Pantalla previa: se elige tipo de partido, puntos, cambios y nombres.
/// Diseñada para caber sin scroll en horizontal (poco alto disponible).
class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key, this.onStart});

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
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // -------- Columna izquierda: título + pelota + EMPEZAR --------
                Expanded(
                  flex: 32,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        BouncingBall(size: 108),
                        const SizedBox(height: 12),
                        const Text('Nuevo partido',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 34,
                                height: 1,
                                fontWeight: FontWeight.w900,
                                color: Colors.white)),
                        const SizedBox(height: 4),
                        Text('Configura y pulsa EMPEZAR',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.92))),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.sunsetDeep,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                            ),
                            onPressed: _start,
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('EMPEZAR',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // -------- Columna derecha: configuración (2 columnas) --------
                Expanded(
                  flex: 68,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 16),
                    decoration: BoxDecoration(
                      color: dark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Fila 1: nombres + VS
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _a,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 19, fontWeight: FontWeight.w700),
                                decoration: InputDecoration(
                                  labelText: 'Equipo A',
                                  labelStyle: const TextStyle(fontSize: 14),
                                  border: const OutlineInputBorder(),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 14),
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('VS',
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900)),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _b,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 19, fontWeight: FontWeight.w700),
                                decoration: InputDecoration(
                                  labelText: 'Equipo B',
                                  labelStyle: const TextStyle(fontSize: 14),
                                  border: const OutlineInputBorder(),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Fila 2: tipo + números
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 46,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _label('Tipo de partido'),
                                  SegmentedButton<MatchType>(
                                    showSelectedIcon: false,
                                    style: const ButtonStyle(
                                        visualDensity: VisualDensity.compact),
                                    segments: const [
                                      ButtonSegment(
                                          value: MatchType.single,
                                          label: Text('Único')),
                                      ButtonSegment(
                                          value: MatchType.bestOf3,
                                          label: Text('Mejor de 3')),
                                    ],
                                    selected: {_setup.type},
                                    onSelectionChanged: (v) => setState(() =>
                                        _setup = _setup.copyWith(type: v.first)),
                                  ),
                                  if (_setup.type == MatchType.bestOf3) ...[
                                    const SizedBox(height: 8),
                                    _numRow(
                                      'Set decisivo',
                                      _setup.decidingPoints,
                                      5,
                                      21,
                                      (v) => setState(() => _setup = _setup
                                          .copyWith(decidingPoints: v)),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Container(
                                width: 1,
                                height: 116,
                                color: Theme.of(context).dividerColor),
                            Expanded(
                              flex: 54,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _numRow(
                                      'Puntos',
                                      _setup.targetPoints,
                                      5,
                                      30,
                                      (v) => setState(() => _setup = _setup
                                          .copyWith(targetPoints: v)),
                                      big: true,
                                      center: true,
                                    ),
                                  ),
                                  Expanded(
                                    child: _numRow(
                                      'Cambios cada',
                                      _setup.switchEvery,
                                      0,
                                      15,
                                      (v) => setState(() => _setup = _setup
                                          .copyWith(switchEvery: v)),
                                      big: true,
                                      center: true,
                                      suffix: _setup.switchEvery == 0
                                          ? 'sin cambios'
                                          : 'puntos',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Text(t.toUpperCase(),
            style: const TextStyle(
                fontSize: 11,
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
      mainAxisSize: MainAxisSize.min,
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
              constraints: const BoxConstraints(minWidth: 60),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Text('$value',
                      style: TextStyle(
                          fontSize: big ? 40 : 28,
                          fontWeight: FontWeight.w900,
                          height: 1)),
                  if (suffix.isNotEmpty)
                    Text(suffix,
                        style: TextStyle(
                            fontSize: 10,
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
      iconSize: 22,
      visualDensity: VisualDensity.compact,
      icon: Icon(icon),
    );
  }
}
