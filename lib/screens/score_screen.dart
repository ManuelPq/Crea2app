import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/matches_provider.dart';
import '../providers/scoreboard_provider.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';

/// Pantalla del marcador. Pensada para usarse en horizontal, a pie de pista.
class ScoreScreen extends StatefulWidget {
  const ScoreScreen({super.key});

  @override
  State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> with WidgetsBindingObserver {
  final SoundService _sound = const SoundService();
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Refresca el cronómetro cada segundo.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Refresca el cronómetro cada segundo.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) setState(() {});
  }

  void _onPoint(String team, ScoreboardProvider score) {
    final result = score.addPoint(team);
    if (score.settings.soundEnabled) {
      if (result == 'match') {
        _sound.matchWon();
      } else if (result == 'set') {
        _sound.setWon();
      } else {
        _sound.point();
      }
    }
    if (result == 'match') {
      _onMatchFinished(score);
    } else if (result == 'set') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text('¡Set para ${score.completedSets.last.wonByA ? score.teamA : score.teamB}!'),
        ),
      );
    }
  }

  Future<void> _onMatchFinished(ScoreboardProvider score) async {
    final record = score.buildRecord();
    final save = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('¡Partido terminado! 🏐'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ganador: ${record.winnerName}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Sets: ${record.setsScore}'),
            Text('Puntos: ${record.setsDetail}'),
            const SizedBox(height: 12),
            const Text('¿Guardar en el historial?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (save == true && mounted) {
      await context.read<MatchesProvider>().addMatch(record);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Partido guardado en el historial ✅')),
        );
      }
    }
    if (mounted) score.resetMatch();
  }

  Future<void> _editNames(ScoreboardProvider score) async {
    final a = TextEditingController(text: score.teamA);
    final b = TextEditingController(text: score.teamB);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nombres de los equipos'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: a,
              decoration: const InputDecoration(labelText: 'Equipo A (izquierda)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: b,
              decoration: const InputDecoration(labelText: 'Equipo B (derecha)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (ok == true) score.setNames(a.text, b.text);
  }

  Future<void> _newMatch(ScoreboardProvider score) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuevo partido'),
        content: const Text('¿Reiniciar el marcador? Se perderán los puntos actuales.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reiniciar'),
          ),
        ],
      ),
    );
    if (confirm == true) score.resetMatch();
  }

  @override
  Widget build(BuildContext context) {
    final score = context.watch<ScoreboardProvider>();
    final dark = Theme.of(context).brightness == Brightness.dark;

    // Refresco visual del cronómetro una vez por segundo.
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
          child: Column(
            children: [
              _topBar(score, dark),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _TeamPanel(
                        name: score.sidesSwapped ? score.teamB : score.teamA,
                        points: score.sidesSwapped ? score.pointsB : score.pointsA,
                        setsWon:
                            score.sidesSwapped ? score.setsWonB : score.setsWonA,
                        gradient: score.sidesSwapped
                            ? AppGradients.teamB
                            : AppGradients.teamA,
                        onAdd: () => _onPoint(score.sidesSwapped ? 'b' : 'a', score),
                        onRemove: () => score.removePoint(
                            score.sidesSwapped ? 'b' : 'a'),
                        onEditName: () => _editNames(score),
                        align: Alignment.centerLeft,
                        dark: dark,
                      ),
                    ),
                    _centerStrip(score, dark),
                    Expanded(
                      child: _TeamPanel(
                        name: score.sidesSwapped ? score.teamA : score.teamB,
                        points: score.sidesSwapped ? score.pointsA : score.pointsB,
                        setsWon:
                            score.sidesSwapped ? score.setsWonA : score.setsWonB,
                        gradient: score.sidesSwapped
                            ? AppGradients.teamA
                            : AppGradients.teamB,
                        onAdd: () => _onPoint(score.sidesSwapped ? 'a' : 'b', score),
                        onRemove: () => score.removePoint(
                            score.sidesSwapped ? 'a' : 'b'),
                        onEditName: () => _editNames(score),
                        align: Alignment.centerRight,
                        dark: dark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar(ScoreboardProvider score, bool dark) {
    final onColor = dark ? Colors.white : AppColors.ink;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.sports_volleyball, size: 30),
          const SizedBox(width: 8),
          Text(
            'Voley Score',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: onColor,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(width: 16),
          _pill(score.currentSetLabel, onColor),
          const Spacer(),
          _timerChip(score),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            tooltip: 'Deshacer',
            onPressed: score.canUndo ? score.undo : null,
            icon: const Icon(Icons.undo),
          ),
          const SizedBox(width: 6),
          IconButton.filledTonal(
            tooltip: 'Reiniciar partido',
            onPressed: () => _newMatch(score),
            icon: const Icon(Icons.restart_alt),
          ),
        ],
      ),
    );
  }

  Widget _pill(String text, Color onColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: onColor, fontWeight: FontWeight.w700, fontSize: 14),
      ),
    );
  }

  Widget _timerChip(ScoreboardProvider score) {
    final e = score.elapsed;
    final mm = e.inMinutes.toString().padLeft(2, '0');
    final ss = (e.inSeconds % 60).toString().padLeft(2, '0');
    return InkWell(
      onTap: score.toggleTimer,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.30),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              score.timerRunning ? Icons.pause_circle_filled : Icons.play_circle_fill,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              '$mm:$ss',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _centerStrip(ScoreboardProvider score, bool dark) {
    final onColor = dark ? Colors.white70 : AppColors.ink;
    return Container(
      width: 96,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton.filled(
            tooltip: 'Intercambiar lados',
            onPressed: score.swapSides,
            icon: const Icon(Icons.swap_horiz),
          ),
          const SizedBox(height: 14),
          Text(
            '${score.setsWonA} - ${score.setsWonB}',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: onColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'SETS',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
              color: onColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamPanel extends StatelessWidget {
  const _TeamPanel({
    required this.name,
    required this.points,
    required this.setsWon,
    required this.gradient,
    required this.onAdd,
    required this.onRemove,
    required this.onEditName,
    required this.align,
    required this.dark,
  });

  final String name;
  final int points;
  final int setsWon;
  final Gradient gradient;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onEditName;
  final Alignment align;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(26),
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(26),
            onTap: onAdd,
            onLongPress: onRemove,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Column(
                crossAxisAlignment: align == Alignment.centerLeft
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.end,
                children: [
                  // Nombre + sets ganados
                  GestureDetector(
                    onTap: onEditName,
                    child: Row(
                      mainAxisAlignment: align == Alignment.centerLeft
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.end,
                      children: [
                        if (align == Alignment.centerLeft)
                          _nameBlock()
                        else
                          _setDots(),
                        if (align == Alignment.centerLeft)
                          const SizedBox(width: 10),
                        if (align == Alignment.centerLeft) _setDots(),
                        if (align == Alignment.centerRight)
                          const SizedBox(width: 10),
                        if (align == Alignment.centerRight) _nameBlock(),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Número gigante
                  Align(
                    alignment: align == Alignment.centerLeft
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: Text(
                      '$points',
                      style: const TextStyle(
                        fontSize: 128,
                        height: 0.9,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        fontFeatures: [FontFeature.tabularFigures()],
                        shadows: [
                          Shadow(
                            color: Color(0x44000000),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Botones -1  /  +1
                  Row(
                    mainAxisAlignment: align == Alignment.centerLeft
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.end,
                    children: [
                      _roundBtn(Icons.remove, onRemove, 'Restar punto'),
                      const SizedBox(width: 10),
                      _roundBtn(Icons.add, onAdd, 'Sumar punto'),
                      const SizedBox(width: 12),
                      Text(
                        'Toca para +1',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _nameBlock() {
    return Flexible(
      child: Column(
        crossAxisAlignment: align == Alignment.centerLeft
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Text(
            'Toca el nombre para editar',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }

  Widget _setDots() {
    return Row(
      children: [
        for (int i = 0; i < 2; i++)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < setsWon
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.30),
            ),
          ),
      ],
    );
  }

  Widget _roundBtn(IconData icon, VoidCallback onTap, String tip) {
    return Tooltip(
      message: tip,
      child: Material(
        color: Colors.white.withValues(alpha: 0.25),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
        ),
      ),
    );
  }
}
