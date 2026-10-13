import 'dart:convert';

/// Tipo de partido.
/// - single: partido único (a N puntos). Es lo habitual en playa.
/// - bestOf3: al mejor de 3 sets (2 sets a N, el 3º más corto).
enum MatchType { single, bestOf3 }

extension MatchTypeX on MatchType {
  String get label => this == MatchType.single
      ? 'Partido único'
      : 'Al mejor de 3 sets';

  String get description => this == MatchType.single
      ? 'Un solo set hasta los puntos objetivo'
      : 'Gana quien gane 2 sets (el 3º más corto)';
}

/// Estado de un partido en el historial.
enum MatchStatus { finished, trash }

/// Configuración elegida ANTES de empezar un partido.
class GameSetup {
  final String teamA;
  final String teamB;
  final MatchType type;
  final int targetPoints; // puntos para finalizar (por defecto 21)
  final int switchEvery; // cambio de pista cada N puntos (por defecto 7)
  final int decidingPoints; // puntos del set decisivo en bestOf3 (por defecto 15)

  const GameSetup({
    this.teamA = 'Equipo A',
    this.teamB = 'Equipo B',
    this.type = MatchType.single,
    this.targetPoints = 21,
    this.switchEvery = 7,
    this.decidingPoints = 15,
  });

  GameSetup copyWith({
    String? teamA,
    String? teamB,
    MatchType? type,
    int? targetPoints,
    int? switchEvery,
    int? decidingPoints,
  }) =>
      GameSetup(
        teamA: teamA ?? this.teamA,
        teamB: teamB ?? this.teamB,
        type: type ?? this.type,
        targetPoints: targetPoints ?? this.targetPoints,
        switchEvery: switchEvery ?? this.switchEvery,
        decidingPoints: decidingPoints ?? this.decidingPoints,
      );
}

/// Un set dentro de un partido (solo se usa en bestOf3).
class GameSet {
  final int pointsA;
  final int pointsB;

  const GameSet({required this.pointsA, required this.pointsB});

  bool get wonByA => pointsA > pointsB;

  Map<String, dynamic> toJson() => {'a': pointsA, 'b': pointsB};

  factory GameSet.fromJson(Map<String, dynamic> j) =>
      GameSet(pointsA: (j['a'] ?? 0) as int, pointsB: (j['b'] ?? 0) as int);
}

/// Un partido guardado en el historial / papelera.
class MatchRecord {
  final String id;
  final String teamA;
  final String teamB;
  final int pointsA;
  final int pointsB;
  final int setsWonA;
  final int setsWonB;
  final List<GameSet> completedSets;
  final MatchType type;
  final int targetPoints;
  final int switchEvery;
  final DateTime playedAt;
  final Duration duration;
  MatchStatus status;

  MatchRecord({
    required this.id,
    required this.teamA,
    required this.teamB,
    required this.pointsA,
    required this.pointsB,
    this.setsWonA = 0,
    this.setsWonB = 0,
    this.completedSets = const [],
    this.type = MatchType.single,
    this.targetPoints = 21,
    this.switchEvery = 7,
    required this.playedAt,
    this.duration = Duration.zero,
    this.status = MatchStatus.finished,
  });

  bool get winnerIsA => pointsA > pointsB;
  String get winnerName => winnerIsA ? teamA : teamB;
  String get loserName => winnerIsA ? teamB : teamA;

  /// Marcador del último set, p.ej. "21 - 18".
  String get finalScore => '$pointsA - $pointsB';

  /// Resultado de sets (solo bestOf3), p.ej. "2 - 1".
  String get setsScore => '$setsWonA - $setsWonB';

  /// Detalle de sets, p.ej. "21-18 · 19-21 · 15-11".
  String get setsDetail =>
      completedSets.map((s) => '${s.pointsA}-${s.pointsB}').join('  ·  ');

  Map<String, dynamic> toJson() => {
        'id': id,
        'teamA': teamA,
        'teamB': teamB,
        'pointsA': pointsA,
        'pointsB': pointsB,
        'setsWonA': setsWonA,
        'setsWonB': setsWonB,
        'completedSets': completedSets.map((s) => s.toJson()).toList(),
        'type': type.name,
        'targetPoints': targetPoints,
        'switchEvery': switchEvery,
        'playedAt': playedAt.toIso8601String(),
        'durationMs': duration.inMilliseconds,
        'status': status.name,
      };

  factory MatchRecord.fromJson(Map<String, dynamic> j) => MatchRecord(
        id: j['id'] as String,
        teamA: j['teamA'] as String? ?? 'Equipo A',
        teamB: j['teamB'] as String? ?? 'Equipo B',
        pointsA: (j['pointsA'] ?? 0) as int,
        pointsB: (j['pointsB'] ?? 0) as int,
        setsWonA: (j['setsWonA'] ?? 0) as int,
        setsWonB: (j['setsWonB'] ?? 0) as int,
        completedSets: (j['completedSets'] as List<dynamic>? ?? [])
            .map((e) => GameSet.fromJson(e as Map<String, dynamic>))
            .toList(),
        type: MatchType.values.firstWhere(
          (t) => t.name == j['type'],
          orElse: () => MatchType.single,
        ),
        targetPoints: (j['targetPoints'] ?? 21) as int,
        switchEvery: (j['switchEvery'] ?? 7) as int,
        playedAt:
            DateTime.tryParse(j['playedAt'] as String? ?? '') ?? DateTime.now(),
        duration: Duration(milliseconds: (j['durationMs'] ?? 0) as int),
        status: MatchStatus.values.firstWhere(
          (s) => s.name == j['status'],
          orElse: () => MatchStatus.finished,
        ),
      );

  static String encodeList(List<MatchRecord> list) =>
      jsonEncode(list.map((m) => m.toJson()).toList());

  static List<MatchRecord> decodeList(String raw) {
    if (raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => MatchRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

/// Ajustes persistentes de la app (valores por defecto del setup).
class AppSettings {
  final MatchType defaultType;
  final int defaultTargetPoints;
  final int defaultSwitchEvery;
  final int defaultDecidingPoints;
  final bool soundEnabled;
  final bool darkMode;

  const AppSettings({
    this.defaultType = MatchType.single,
    this.defaultTargetPoints = 21,
    this.defaultSwitchEvery = 7,
    this.defaultDecidingPoints = 15,
    this.soundEnabled = true,
    this.darkMode = false,
  });

  GameSetup get defaultSetup => GameSetup(
        type: defaultType,
        targetPoints: defaultTargetPoints,
        switchEvery: defaultSwitchEvery,
        decidingPoints: defaultDecidingPoints,
      );

  AppSettings copyWith({
    MatchType? defaultType,
    int? defaultTargetPoints,
    int? defaultSwitchEvery,
    int? defaultDecidingPoints,
    bool? soundEnabled,
    bool? darkMode,
  }) =>
      AppSettings(
        defaultType: defaultType ?? this.defaultType,
        defaultTargetPoints: defaultTargetPoints ?? this.defaultTargetPoints,
        defaultSwitchEvery: defaultSwitchEvery ?? this.defaultSwitchEvery,
        defaultDecidingPoints: defaultDecidingPoints ?? this.defaultDecidingPoints,
        soundEnabled: soundEnabled ?? this.soundEnabled,
        darkMode: darkMode ?? this.darkMode,
      );
}
