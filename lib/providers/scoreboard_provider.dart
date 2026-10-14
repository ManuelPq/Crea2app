import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/match_record.dart';

/// Resultado de sumar un punto, para que la UI reaccione.
enum PointEvent { none, courtSwitch, setWon, matchWon }

class _Snapshot {
  final int pointsA;
  final int pointsB;
  final int setsWonA;
  final int setsWonB;
  final List<GameSet> completedSets;
  final bool courtSwitched;

  _Snapshot({
    required this.pointsA,
    required this.pointsB,
    required this.setsWonA,
    required this.setsWonB,
    required this.completedSets,
    required this.courtSwitched,
  });
}

/// Lógica del marcador de vóley playa.
/// Por defecto: partido único a 21 puntos, con cambio de pista cada 7.
class ScoreboardProvider extends ChangeNotifier {
  GameSetup setup = const GameSetup();

  int pointsA = 0;
  int pointsB = 0;
  int setsWonA = 0;
  int setsWonB = 0;
  final List<GameSet> completedSets = [];

  bool matchFinished = false;
  bool courtSwitched = false; // el equipo A ha cambiado de lado por última vez

  final List<_Snapshot> _undoStack = [];

  final Stopwatch _stopwatch = Stopwatch();
  bool timerRunning = false;

  AppSettings settings = const AppSettings();

  // ---------- Config ----------
  void applySettings(AppSettings s) {
    settings = s;
    notifyListeners();
  }

  /// Actualiza los nombres sin reiniciar el marcador.
  void updateNames(String a, String b) {
    setup = setup.copyWith(
      teamA: a.trim().isEmpty ? 'Equipo A' : a.trim(),
      teamB: b.trim().isEmpty ? 'Equipo B' : b.trim(),
    );
    notifyListeners();
  }

  void startMatch(GameSetup s) {
    setup = s;
    pointsA = 0;
    pointsB = 0;
    setsWonA = 0;
    setsWonB = 0;
    completedSets.clear();
    _undoStack.clear();
    matchFinished = false;
    courtSwitched = false;
    _stopwatch.reset();
    _stopwatch.start();
    timerRunning = true;
    notifyListeners();
  }

  // ---------- Objetivo actual ----------
  int get currentTarget {
    if (setup.type == MatchType.bestOf3 && completedSets.length >= 2) {
      return setup.decidingPoints;
    }
    return setup.targetPoints;
  }

  String get modeLabel {
    if (setup.type == MatchType.single) {
      return 'Partido único · a ${setup.targetPoints} · cambios cada ${setup.switchEvery}';
    }
    final n = completedSets.length + 1;
    return 'Al mejor de 3 · Set $n (a $currentTarget) · cambios cada ${setup.switchEvery}';
  }

  int get totalPoints => pointsA + pointsB;

  /// Próximo punto en el que habrá cambio de pista (o null si no aplica).
  int? get nextSwitchAt {
    if (setup.switchEvery <= 0) return null;
    final t = totalPoints;
    return ((t ~/ setup.switchEvery) + 1) * setup.switchEvery;
  }

  bool get canUndo => _undoStack.isNotEmpty;
  Duration get elapsed => _stopwatch.elapsed;

  // ---------- Puntos ----------
  void _pushUndo() {
    _undoStack.add(
      _Snapshot(
        pointsA: pointsA,
        pointsB: pointsB,
        setsWonA: setsWonA,
        setsWonB: setsWonB,
        completedSets: List<GameSet>.from(completedSets),
        courtSwitched: courtSwitched,
      ),
    );
    if (_undoStack.length > 200) _undoStack.removeAt(0);
  }

  PointEvent addPoint(String team) {
    if (matchFinished) return PointEvent.none;
    _pushUndo();

    if (team == 'a') {
      pointsA++;
    } else {
      pointsB++;
    }

    final target = currentTarget;
    final aWonSet = pointsA >= target && (pointsA - pointsB) >= 2;
    final bWonSet = pointsB >= target && (pointsB - pointsA) >= 2;

    // ¿Fin de set / partido?
    if (aWonSet || bWonSet) {
      if (setup.type == MatchType.single) {
        matchFinished = true;
        _stopwatch.stop();
        timerRunning = false;
        notifyListeners();
        return PointEvent.matchWon;
      }
      // bestOf3: cerrar set
      completedSets.add(GameSet(pointsA: pointsA, pointsB: pointsB));
      if (aWonSet) {
        setsWonA++;
      } else {
        setsWonB++;
      }
      pointsA = 0;
      pointsB = 0;
      if (setsWonA == 2 || setsWonB == 2) {
        matchFinished = true;
        _stopwatch.stop();
        timerRunning = false;
        notifyListeners();
        return PointEvent.matchWon;
      }
      notifyListeners();
      return PointEvent.setWon;
    }

    // ¿Cambio de pista? Cada vez que el total es múltiplo de switchEvery.
    if (setup.switchEvery > 0 && totalPoints % setup.switchEvery == 0) {
      courtSwitched = !courtSwitched;
      notifyListeners();
      return PointEvent.courtSwitch;
    }

    notifyListeners();
    return PointEvent.none;
  }

  void removePoint(String team) {
    if (matchFinished) return;
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
    courtSwitched = s.courtSwitched;
    matchFinished = false;
    notifyListeners();
  }

  // ---------- Cronómetro ----------
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

  // ---------- Registro ----------
  MatchRecord buildRecord() {
    return MatchRecord(
      id: const Uuid().v4(),
      teamA: setup.teamA,
      teamB: setup.teamB,
      pointsA: pointsA,
      pointsB: pointsB,
      setsWonA: setsWonA,
      setsWonB: setsWonB,
      completedSets: List<GameSet>.from(completedSets),
      type: setup.type,
      targetPoints: setup.targetPoints,
      switchEvery: setup.switchEvery,
      playedAt: DateTime.now(),
      duration: _stopwatch.elapsed,
      colorA: setup.colorA,
      colorB: setup.colorB,
    );
  }

  void reset() {
    pointsA = 0;
    pointsB = 0;
    setsWonA = 0;
    setsWonB = 0;
    completedSets.clear();
    _undoStack.clear();
    matchFinished = false;
    courtSwitched = false;
    _stopwatch.reset();
    timerRunning = false;
    notifyListeners();
  }
}
