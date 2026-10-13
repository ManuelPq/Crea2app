import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/match_record.dart';

/// Estado interno para poder deshacer (snapshot).
class _Snapshot {
  final int pointsA;
  final int pointsB;
  final int setsWonA;
  final int setsWonB;
  final List<GameSet> completedSets;

  _Snapshot({
    required this.pointsA,
    required this.pointsB,
    required this.setsWonA,
    required this.setsWonB,
    required this.completedSets,
  });
}

/// Lógica completa del marcador de vóley.
class ScoreboardProvider extends ChangeNotifier {
  ScoreboardProvider();

  // Nombres
  String teamA = 'Equipo A';
  String teamB = 'Equipo B';

  // Puntuación del set actual
  int pointsA = 0;
  int pointsB = 0;

  // Sets ganados
  int setsWonA = 0;
  int setsWonB = 0;

  // Sets completados
  final List<GameSet> completedSets = [];

  // Historial para deshacer
  final List<_Snapshot> _undoStack = [];

  // Ajustes
  AppSettings settings = const AppSettings();

  // Cronómetro
  final Stopwatch _stopwatch = Stopwatch();
  bool timerRunning = false;

  // Partido finalizado pendiente de guardar
  bool matchFinished = false;

  // Cambio de lados (interfaz)
  bool sidesSwapped = false;

  // ---------- Configuración ----------
  void applySettings(AppSettings s) {
    settings = s;
    notifyListeners();
  }

  void setNames(String a, String b) {
    teamA = a.trim().isEmpty ? 'Equipo A' : a.trim();
    teamB = b.trim().isEmpty ? 'Equipo B' : b.trim();
    notifyListeners();
  }

  // ---------- Objetivo del set actual ----------
  /// En vóley playa: sets a 21 y set decisivo (3º) a 15.
  int get currentSetTarget {
    final isDeciding = completedSets.length >= 2;
    if (isDeciding && settings.tieBreakTo15) return settings.decidingSetPoints;
    return settings.pointsPerSet;
  }

  String get currentSetLabel {
    final n = completedSets.length + 1;
    final isDeciding = completedSets.length >= 2;
    if (isDeciding) return 'Set $n (decisivo a $currentSetTarget)';
    return 'Set $n · a $currentSetTarget';
  }

  // ---------- Puntos ----------
  void _pushUndo() {
    _undoStack.add(_Snapshot(
      pointsA: pointsA,
      pointsB: pointsB,
      setsWonA: setsWonA,
      setsWonB: setsWonB,
      completedSets: List<GameSet>.from(completedSets),
    ));
    if (_undoStack.length > 100) _undoStack.removeAt(0);
  }

  bool get canUndo => _undoStack.isNotEmpty;

  /// Devuelve true si se ganó el set / partido (para que la UI reaccione).
  bool _checkSetWin() {
    final target = currentSetTarget;
    final aWon = pointsA >= target && (pointsA - pointsB) >= 2;
    final bWon = pointsB >= target && (pointsB - pointsA) >= 2;
    if (!aWon && !bWon) return false;

    completedSets.add(GameSet(pointsA: pointsA, pointsB: pointsB));
    if (aWon) {
      setsWonA++;
    } else {
      setsWonB++;
    }
    pointsA = 0;
    pointsB = 0;

    // ¿Partido terminado? (mejor de 3)
    if (setsWonA == 2 || setsWonB == 2) {
      matchFinished = true;
      _stopwatch.stop();
      timerRunning = false;
    }
    return true;
  }

  /// Añade un punto. 'a' = equipo A, 'b' = equipo B.
  /// Devuelve 'set' si se cerró un set, 'match' si se acabó el partido, o null.
  String? addPoint(String team) {
    if (matchFinished) return null;
    _pushUndo();
    if (team == 'a') {
      pointsA++;
    } else {
      pointsB++;
    }
    if (!_stopwatch.isRunning) {
      _stopwatch.start();
      timerRunning = true;
    }
    final closed = _checkSetWin();
    notifyListeners();
    if (matchFinished) return 'match';
    if (closed) return 'set';
    return null;
  }

  void removePoint(String team) {
    _pushUndo();
    if (team == 'a' && pointsA > 0) pointsA--;
    if (team == 'b' && pointsB > 0) pointsB--;
    notifyListeners();
  }

  void undo() {
    if (_undoStack.isEmpty) return;
    final s = _undoStack.removeLast();
    pointsA = s.pointsA;
    pointsB = s.pointsB;
    setsWonA = s.setsWonA;
    setsWonB = s.setsWonB;
    completedSets
      ..clear()
      ..addAll(s.completedSets);
    matchFinished = false;
    notifyListeners();
  }

  // ---------- Cronómetro ----------
  Duration get elapsed => _stopwatch.elapsed;

  void toggleTimer() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
      timerRunning = false;
    } else {
      _stopwatch.start();
      timerRunning = true;
    }
    notifyListeners();
  }

  void swapSides() {
    sidesSwapped = !sidesSwapped;
    notifyListeners();
  }

  // ---------- Crear registro del partido ----------
  MatchRecord buildRecord() {
    return MatchRecord(
      id: const Uuid().v4(),
      teamA: teamA,
      teamB: teamB,
      sets: List<GameSet>.from(completedSets),
      setsWonA: setsWonA,
      setsWonB: setsWonB,
      playedAt: DateTime.now(),
      duration: _stopwatch.elapsed,
    );
  }

  // ---------- Reiniciar ----------
  void resetMatch({bool keepNames = true}) {
    pointsA = 0;
    pointsB = 0;
    setsWonA = 0;
    setsWonB = 0;
    completedSets.clear();
    _undoStack.clear();
    matchFinished = false;
    _stopwatch.reset();
    timerRunning = false;
    if (!keepNames) {
      teamA = 'Equipo A';
      teamB = 'Equipo B';
    }
    notifyListeners();
  }
}
