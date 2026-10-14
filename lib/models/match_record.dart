import 'dart:convert';

/// Tipo de partido.
/// - single: partido único (a N puntos). Es lo habitual en playa.
/// - bestOf3: al mejor de 3 sets (2 sets a N, el 3º más corto).
enum MatchType { single, bestOf3 }

extension MatchTypeX on MatchType {
  String get label =>
      this == MatchType.single ? 'Partido único' : 'Al mejor de 3 sets';

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
  final int
  decidingPoints; // puntos del set decisivo en bestOf3 (por defecto 15)

  /// Color de fondo de cada equipo (ARGB).
  final int colorA;
  final int colorB;

  const GameSetup({
    this.teamA = 'Equipo A',
    this.teamB = 'Equipo B',
    this.type = MatchType.single,
    this.targetPoints = 21,
    this.switchEvery = 7,
    this.decidingPoints = 15,
    this.colorA = 0xFFE53935, // rojo
    this.colorB = 0xFF1E6FEB, // azul
  });

  GameSetup copyWith({
    String? teamA,
    String? teamB,
    MatchType? type,
    int? targetPoints,
    int? switchEvery,
    int? decidingPoints,
    int? colorA,
    int? colorB,
  }) => GameSetup(
    teamA: teamA ?? this.teamA,
    teamB: teamB ?? this.teamB,
    type: type ?? this.type,
    targetPoints: targetPoints ?? this.targetPoints,
    switchEvery: switchEvery ?? this.switchEvery,
    decidingPoints: decidingPoints ?? this.decidingPoints,
    colorA: colorA ?? this.colorA,
    colorB: colorB ?? this.colorB,
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

  /// Color de fondo de cada equipo (ARGB). Opcional para datos antiguos.
  final int? colorA;
  final int? colorB;
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
    this.colorA,
    this.colorB,
    this.status = MatchStatus.finished,
  });

  /// Gana el equipo A. En "al mejor de 3" manda el número de sets ganados
  /// (los puntos del último set se reinician a 0, por eso no sirven aquí).
  bool get winnerIsA =>
      type == MatchType.bestOf3 ? setsWonA > setsWonB : pointsA > pointsB;
  String get winnerName => winnerIsA ? teamA : teamB;
  String get loserName => winnerIsA ? teamB : teamA;

  /// Marcador del último set, p.ej. "21 - 18".
  String get finalScore => '$pointsA - $pointsB';

  /// Resultado de sets (solo bestOf3), p.ej. "2 - 1".
  String get setsScore => '$setsWonA - $setsWonB';

  /// Detalle de sets, p.ej. "21-18 · 19-21 · 15-11".
  String get setsDetail =>
      completedSets.map((s) => '${s.pointsA}-${s.pointsB}').join('  ·  ');

  /// Marcador principal que se muestra en grande:
  /// - bestOf3 -> sets ganados ("2 - 1")
  /// - single  -> puntos del set ("21 - 18")
  String get headlineScore =>
      type == MatchType.bestOf3 ? setsScore : finalScore;

  /// Etiqueta del marcador principal.
  String get headlineLabel => type == MatchType.bestOf3 ? 'sets' : 'puntos';

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
    'colorA': colorA,
    'colorB': colorB,
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
    colorA: (j['colorA'] as num?)?.toInt(),
    colorB: (j['colorB'] as num?)?.toInt(),
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

  /// Color de fondo por defecto de cada equipo (ARGB).
  final int defaultColorA;
  final int defaultColorB;

  const AppSettings({
    this.defaultType = MatchType.single,
    this.defaultTargetPoints = 21,
    this.defaultSwitchEvery = 7,
    this.defaultDecidingPoints = 15,
    this.soundEnabled = true,
    this.darkMode = false,
    this.defaultColorA = 0xFFE53935, // rojo
    this.defaultColorB = 0xFF1E6FEB, // azul
  });

  GameSetup get defaultSetup => GameSetup(
    type: defaultType,
    targetPoints: defaultTargetPoints,
    switchEvery: defaultSwitchEvery,
    decidingPoints: defaultDecidingPoints,
    colorA: defaultColorA,
    colorB: defaultColorB,
  );

  AppSettings copyWith({
    MatchType? defaultType,
    int? defaultTargetPoints,
    int? defaultSwitchEvery,
    int? defaultDecidingPoints,
    bool? soundEnabled,
    bool? darkMode,
    int? defaultColorA,
    int? defaultColorB,
  }) => AppSettings(
    defaultType: defaultType ?? this.defaultType,
    defaultTargetPoints: defaultTargetPoints ?? this.defaultTargetPoints,
    defaultSwitchEvery: defaultSwitchEvery ?? this.defaultSwitchEvery,
    defaultDecidingPoints: defaultDecidingPoints ?? this.defaultDecidingPoints,
    soundEnabled: soundEnabled ?? this.soundEnabled,
    darkMode: darkMode ?? this.darkMode,
    defaultColorA: defaultColorA ?? this.defaultColorA,
    defaultColorB: defaultColorB ?? this.defaultColorB,
  );
}
