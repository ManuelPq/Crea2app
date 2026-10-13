import 'dart:convert';

/// Estado de un partido en el historial.
enum MatchStatus { finished, trash }

/// Un set dentro de un partido.
class GameSet {
  final int pointsA;
  final int pointsB;

  const GameSet({required this.pointsA, required this.pointsB});

  bool get wonByA => pointsA > pointsB;

  Map<String, dynamic> toJson() => {'a': pointsA, 'b': pointsB};

  factory GameSet.fromJson(Map<String, dynamic> j) =>
      GameSet(pointsA: (j['a'] ?? 0) as int, pointsB: (j['b'] ?? 0) as int);
}

/// Un partido completo, guardado en el historial / papelera.
class MatchRecord {
  final String id;
  final String teamA;
  final String teamB;
  final List<GameSet> sets;
  final int setsWonA;
  final int setsWonB;
  final DateTime playedAt;
  final Duration duration;
  MatchStatus status;

  MatchRecord({
    required this.id,
    required this.teamA,
    required this.teamB,
    required this.sets,
    required this.setsWonA,
    required this.setsWonB,
    required this.playedAt,
    this.duration = Duration.zero,
    this.status = MatchStatus.finished,
  });

  /// ¿Ganó el equipo A el partido?
  bool get winnerIsA => setsWonA > setsWonB;

  String get winnerName => winnerIsA ? teamA : teamB;
  String get loserName => winnerIsA ? teamB : teamA;

  /// Resultado por sets, p.ej. "2 - 1".
  String get setsScore => '$setsWonA - $setsWonB';

  /// Detalle de cada set, p.ej. "21-18 · 19-21 · 15-11".
  String get setsDetail =>
      sets.map((s) => '${s.pointsA}-${s.pointsB}').join('  ·  ');

  Map<String, dynamic> toJson() => {
        'id': id,
        'teamA': teamA,
        'teamB': teamB,
        'sets': sets.map((s) => s.toJson()).toList(),
        'setsWonA': setsWonA,
        'setsWonB': setsWonB,
        'playedAt': playedAt.toIso8601String(),
        'durationMs': duration.inMilliseconds,
        'status': status.name,
      };

  factory MatchRecord.fromJson(Map<String, dynamic> j) => MatchRecord(
        id: j['id'] as String,
        teamA: j['teamA'] as String? ?? 'Equipo A',
        teamB: j['teamB'] as String? ?? 'Equipo B',
        sets: (j['sets'] as List<dynamic>? ?? [])
            .map((e) => GameSet.fromJson(e as Map<String, dynamic>))
            .toList(),
        setsWonA: (j['setsWonA'] ?? 0) as int,
        setsWonB: (j['setsWonB'] ?? 0) as int,
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

/// Configuración persistente de la app.
class AppSettings {
  final int pointsPerSet;
  final bool tieBreakTo15;
  final int decidingSetPoints;
  final bool soundEnabled;
  final bool darkMode;

  const AppSettings({
    this.pointsPerSet = 21,
    this.tieBreakTo15 = true,
    this.decidingSetPoints = 15,
    this.soundEnabled = true,
    this.darkMode = false,
  });

  AppSettings copyWith({
    int? pointsPerSet,
    bool? tieBreakTo15,
    int? decidingSetPoints,
    bool? soundEnabled,
    bool? darkMode,
  }) =>
      AppSettings(
        pointsPerSet: pointsPerSet ?? this.pointsPerSet,
        tieBreakTo15: tieBreakTo15 ?? this.tieBreakTo15,
        decidingSetPoints: decidingSetPoints ?? this.decidingSetPoints,
        soundEnabled: soundEnabled ?? this.soundEnabled,
        darkMode: darkMode ?? this.darkMode,
      );
}
