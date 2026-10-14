import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/match_record.dart';
import '../providers/matches_provider.dart';
import '../providers/scoreboard_provider.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_menu.dart';
import '../widgets/bouncing_ball.dart';
import 'setup_screen.dart';

/// Pantalla del marcador (horizontal, a pie de pista).
class ScoreScreen extends StatefulWidget {
  const ScoreScreen({
    super.key,
    this.currentIndex = 0,
    this.newMatchSignal = 0,
    this.onNewMatch,
    this.onOpenScoreboard,
    this.onOpenHistory,
    this.onOpenSettings,
  });

  final int currentIndex;
  final int newMatchSignal;
  final VoidCallback? onNewMatch;
  final VoidCallback? onOpenScoreboard;
  final VoidCallback? onOpenHistory;
  final VoidCallback? onOpenSettings;

  @override
  State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> with WidgetsBindingObserver {
  final SoundService _sound = const SoundService();
  Timer? _ticker;
  bool _configuring = true; // al abrir, primero se configura el partido

  // Banner flotante de cambio de pista
  bool _switchBanner = false;
  Timer? _switchTimer;

  // Barra superior que se oculta sola para dejar más sitio al marcador
  bool _controlsVisible = true;
  Timer? _controlsTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    _programarOcultado();
  }

  @override
  void didUpdateWidget(covariant ScoreScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Petición externa de "nuevo partido".
    if (widget.newMatchSignal != oldWidget.newMatchSignal) {
      _irANuevaConfiguracion();
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _switchTimer?.cancel();
    _controlsTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) setState(() {});
  }

  void _programarOcultado() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _controlsVisible = false);
    });
  }

  void _mostrarControles() {
    if (!_controlsVisible) setState(() => _controlsVisible = true);
    _programarOcultado();
  }

  void _toggleControles() {
    if (_controlsVisible) {
      _controlsTimer?.cancel();
      setState(() => _controlsVisible = false);
    } else {
      _mostrarControles();
    }
  }

  /// Vuelve a la pantalla de configuración (nuevo partido).
  void _irANuevaConfiguracion() {
    context.read<ScoreboardProvider>().reset();
    setState(() {
      _configuring = true;
      _controlsVisible = true;
    });
  }

  // ---------------- Puntos ----------------
  void _onPoint(String team, ScoreboardProvider score) {
    if (_switchBanner) {
      _switchTimer?.cancel();
      setState(() => _switchBanner = false);
    }
    final event = score.addPoint(team);
    if (score.settings.soundEnabled) {
      switch (event) {
        case PointEvent.matchWon:
          _sound.matchWon();
          break;
        case PointEvent.setWon:
          _sound.setWon();
          break;
        case PointEvent.courtSwitch:
          _sound.courtSwitch();
          break;
        case PointEvent.none:
          _sound.point();
          break;
      }
    }
    switch (event) {
      case PointEvent.courtSwitch:
        _showSwitchBanner();
        break;
      case PointEvent.matchWon:
        _onMatchFinished(score);
        break;
      case PointEvent.setWon:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(milliseconds: 1200),
            content: Text(
              'Set para ${score.setsWonA > score.setsWonB ? score.setup.teamA : score.setup.teamB}',
            ),
          ),
        );
        break;
      case PointEvent.none:
        break;
    }
  }

  void _showSwitchBanner() {
    setState(() => _switchBanner = true);
    _switchTimer?.cancel();
    _switchTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _switchBanner = false);
    });
  }

  // ---------------- Fin de partido ----------------
  Future<void> _onMatchFinished(ScoreboardProvider score) async {
    final record = score.buildRecord();
    if (mounted) await context.read<MatchesProvider>().addMatch(record);
    if (!mounted) return;

    final action = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 60, vertical: 24),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            BouncingBall(size: 44, animate: false),
            const SizedBox(width: 12),
            const Text(
              '¡Partido terminado!',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    record.teamA,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Expanded(
                  child: Text(
                    record.teamB,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${record.pointsA}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '${record.pointsB}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '🏆 Ganó ${record.winnerName}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            const Text(
              'Guardado en el historial ✅',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(ctx, 'config'),
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text('Nuevo partido'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.sunsetDeep,
                  ),
                  onPressed: () => Navigator.pop(ctx, 'rematch'),
                  icon: const Icon(Icons.replay, size: 18),
                  label: const Text('Revancha'),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (action == 'config') {
      _irANuevaConfiguracion();
    } else {
      // Revancha con la misma configuración
      score.startMatch(score.setup);
      setState(() {
        _controlsVisible = true;
      });
      _programarOcultado();
    }
  }

  Future<void> _editNames(ScoreboardProvider score) async {
    final a = TextEditingController(text: score.setup.teamA);
    final b = TextEditingController(text: score.setup.teamB);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nombres de los equipos'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: a,
              decoration: const InputDecoration(labelText: 'Equipo A'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: b,
              decoration: const InputDecoration(labelText: 'Equipo B'),
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
    if (ok == true) {
      score.updateNames(a.text, b.text);
    }
  }

  // ---------------- Build ----------------
  @override
  Widget build(BuildContext context) {
    if (_configuring) {
      return SetupScreen(
        onOpenSettings: widget.onOpenSettings,
        onStart: () {
          setState(() {
            _configuring = false;
            _controlsVisible = true;
          });
          _programarOcultado();
        },
      );
    }
    final score = context.watch<ScoreboardProvider>();
    final dark = Theme.of(context).brightness == Brightness.dark;

    // Construye el panel de un equipo colocado en un lado concreto.
    // El contenido se alinea según el LADO (no según el equipo), de modo que
    // al cambiar de pista los paneles se intercambian de sitio.
    Widget panelFor(String team, Alignment side) {
      final isA = team == 'a';
      return _TeamPanel(
        label: isA ? 'A' : 'B',
        name: isA ? score.setup.teamA : score.setup.teamB,
        points: isA ? score.pointsA : score.pointsB,
        setsWon: isA ? score.setsWonA : score.setsWonB,
        gradient: AppGradients.forTeam(
          Color(isA ? score.setup.colorA : score.setup.colorB),
        ),
        align: side,
        onAdd: () => _onPoint(team, score),
        onRemove: () => score.removePoint(team),
        onEditName: () => _editNames(score),
      );
    }

    // Al cambiar de pista, los equipos intercambian su lado en la pantalla.
    final leftTeam = score.courtSwitched ? 'b' : 'a';
    final rightTeam = score.courtSwitched ? 'a' : 'b';

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
          child: Stack(
            children: [
              Column(
                children: [
                  AnimatedSize(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    alignment: Alignment.topCenter,
                    child: _controlsVisible
                        ? _topBar(score, dark)
                        : const SizedBox(width: double.infinity),
                  ),
                  _handleBar(),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: panelFor(leftTeam, Alignment.centerLeft),
                        ),
                        _centerStrip(score),
                        Expanded(
                          child: panelFor(rightTeam, Alignment.centerRight),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              _switchBannerOverlay(score),
            ],
          ),
        ),
      ),
    );
  }

  /// Asa flotante que se toca para volver a mostrar la barra superior.
  Widget _handleBar() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      child: _controlsVisible
          ? const SizedBox(width: double.infinity)
          : Align(
              alignment: Alignment.topCenter,
              child: GestureDetector(
                onTap: _mostrarControles,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.only(top: 6, bottom: 2),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Mostrar barra',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _topBar(ScoreboardProvider score, bool dark) {
    final onColor = dark ? Colors.white : AppColors.ink;
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: dark ? 0.30 : 0.24),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        children: [
          Flexible(
            child: Text(
              score.modeLabel,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: onColor,
              ),
            ),
          ),
          const Spacer(),
          _timerChip(score),
          const SizedBox(width: 6),
          IconButton.filledTonal(
            tooltip: 'Deshacer',
            onPressed: score.canUndo ? score.undo : null,
            icon: const Icon(Icons.undo),
          ),
          const SizedBox(width: 6),
          IconButton.filledTonal(
            tooltip: 'Ocultar barra',
            onPressed: _toggleControles,
            icon: const Icon(Icons.keyboard_arrow_up),
          ),
          const SizedBox(width: 6),
          // Menú a la derecha (Nuevo partido / Marcador / Historial / Ajustes)
          AppMenuButton(
            currentIndex: 0,
            onNewMatch: _irANuevaConfiguracion,
            onScoreboard: () {},
            onHistory: () => widget.onOpenHistory?.call(),
            onSettings: () => widget.onOpenSettings?.call(),
          ),
        ],
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.30),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              score.timerRunning
                  ? Icons.pause_circle_filled
                  : Icons.play_circle_fill,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 5),
            Text(
              '$mm:$ss',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _centerStrip(ScoreboardProvider score) {
    final next = score.nextSwitchAt;
    final remaining = next == null ? null : next - score.totalPoints;
    final isMulti = score.setup.type == MatchType.bestOf3;
    return Container(
      width: 128,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BouncingBall(size: 92, animate: !score.matchFinished),
          const SizedBox(height: 8),
          if (isMulti)
            Text(
              '${score.setsWonA} - ${score.setsWonB}',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          const SizedBox(height: 8),
          if (remaining != null && !_switchBanner)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.30),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  const Text(
                    'CAMBIO DE PISTA',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'en $remaining ${remaining == 1 ? "punto" : "puntos"}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _switchBannerOverlay(ScoreboardProvider score) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: _switchBanner ? 1 : 0,
          duration: const Duration(milliseconds: 220),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 22),
              decoration: BoxDecoration(
                gradient: AppGradients.beach,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.swap_horiz, color: Colors.white, size: 46),
                      Icon(Icons.swap_horiz, color: Colors.white, size: 46),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '¡CAMBIO DE PISTA!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${score.totalPoints} puntos · cambiad de lado',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Panel de un equipo con número gigante (~80% de la celda).
class _TeamPanel extends StatelessWidget {
  const _TeamPanel({
    required this.label,
    required this.name,
    required this.points,
    required this.setsWon,
    required this.gradient,
    required this.align,
    required this.onAdd,
    required this.onRemove,
    required this.onEditName,
  });

  final String label;
  final String name;
  final int points;
  final int setsWon;
  final Gradient gradient;
  final Alignment align;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onEditName;

  @override
  Widget build(BuildContext context) {
    final isLeft = align == Alignment.centerLeft;
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
                color: Colors.black.withValues(alpha: 0.20),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(26),
            onTap: onAdd,
            onLongPress: onRemove,
            child: Stack(
              children: [
                Positioned.fill(
                  child: FractionallySizedBox(
                    widthFactor: 0.82,
                    heightFactor: 0.80,
                    alignment: Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Text(
                        '$points',
                        style: const TextStyle(
                          fontSize: 600,
                          height: 0.82,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          leadingDistribution: TextLeadingDistribution.even,
                          shadows: [
                            Shadow(
                              color: Color(0x55000000),
                              blurRadius: 18,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 14,
                  left: isLeft ? null : 18,
                  right: isLeft ? 18 : null,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 46,
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: isLeft ? 16 : null,
                  right: isLeft ? null : 16,
                  child: GestureDetector(
                    onTap: onEditName,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isLeft && setsWon > 0) ...[
                            _dots(),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (isLeft) ...[const SizedBox(width: 8), _dots()],
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: isLeft ? 16 : null,
                  right: isLeft ? null : 16,
                  child: Row(
                    children: [
                      _roundBtn(Icons.remove, onRemove, 'Restar'),
                      const SizedBox(width: 8),
                      _roundBtn(Icons.add, onAdd, 'Sumar +1'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dots() {
    return Row(
      children: [
        for (int i = 0; i < 2; i++)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < setsWon
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.35),
            ),
          ),
      ],
    );
  }

  Widget _roundBtn(IconData icon, VoidCallback onTap, String tip) {
    return Material(
      color: Colors.white.withValues(alpha: 0.28),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}
