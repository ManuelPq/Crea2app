import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/match_record.dart';
import '../providers/scoreboard_provider.dart';
import '../theme/app_theme.dart';

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
              // Columna izquierda: pelota + título
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/pelota.png', width: 130),
                      const SizedBox(height: 18),
                      const Text(
                        'Nuevo partido',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 0.95,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Configura el partido antes de empezar 🏐',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Columna derecha: configuración
              Expanded(
                flex: 6,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(0, 14, 14, 14),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: dark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      // Campos
                      Expanded(
                        flex: 5,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Equipos'),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _a,
                                      decoration: const InputDecoration(
                                        labelText: 'Equipo A',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8),
                                    child: Text('VS',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w900)),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: _b,
                                      decoration: const InputDecoration(
                                        labelText: 'Equipo B',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
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
                                onSelectionChanged: (v) =>
                                    setState(() => _setup = _setup.copyWith(type: v.first)),
                              ),
                              if (_setup.type == MatchType.bestOf3) ...[
                                const SizedBox(height: 12),
                                _numRow(
                                  'Puntos del set decisivo',
                                  _setup.decidingPoints,
                                  5,
                                  21,
                                  (v) => setState(() => _setup =
                                      _setup.copyWith(decidingPoints: v)),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      // Números grandes + botón
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _numRow(
                                      'Puntos para finalizar',
                                      _setup.targetPoints,
                                      5,
                                      30,
                                      (v) => setState(() => _setup =
                                          _setup.copyWith(targetPoints: v)),
                                      big: true,
                                    ),
                                    const SizedBox(height: 12),
                                    _numRow(
                                      'Cambio de pista cada',
                                      _setup.switchEvery,
                                      0,
                                      15,
                                      (v) => setState(() => _setup =
                                          _setup.copyWith(switchEvery: v)),
                                      big: true,
                                      suffix: _setup.switchEvery == 0
                                          ? 'sin cambios'
                                          : 'puntos',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              height: 54,
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
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(title),
        Row(
          children: [
            _circleBtn(Icons.remove, value > min ? () => onChanged(value - 1) : null),
            Container(
              constraints: const BoxConstraints(minWidth: 74),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Text(
                    '$value',
                    style: TextStyle(
                      fontSize: big ? 40 : 30,
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
            _circleBtn(Icons.add, value < max ? () => onChanged(value + 1) : null),
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
