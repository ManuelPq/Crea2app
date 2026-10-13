import 'package:shared_preferences/shared_preferences.dart';

import '../models/match_record.dart';

/// Persistencia local de partidos y ajustes usando SharedPreferences.
class StorageService {
  static const _kMatches = 'matches_v1';
  static const _kPointsPerSet = 'points_per_set';
  static const _kTieBreak = 'tie_break_to15';
  static const _kDecidingPoints = 'deciding_set_points';
  static const _kSound = 'sound_enabled';
  static const _kDark = 'dark_mode';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _p async =>
      _prefs ??= await SharedPreferences.getInstance();

  // ------- Partidos -------
  Future<List<MatchRecord>> loadMatches() async {
    final p = await _p;
    final raw = p.getString(_kMatches) ?? '';
    return MatchRecord.decodeList(raw);
  }

  Future<void> saveMatches(List<MatchRecord> matches) async {
    final p = await _p;
    await p.setString(_kMatches, MatchRecord.encodeList(matches));
  }

  // ------- Ajustes -------
  Future<AppSettings> loadSettings() async {
    final p = await _p;
    return AppSettings(
      pointsPerSet: p.getInt(_kPointsPerSet) ?? 21,
      tieBreakTo15: p.getBool(_kTieBreak) ?? true,
      decidingSetPoints: p.getInt(_kDecidingPoints) ?? 15,
      soundEnabled: p.getBool(_kSound) ?? true,
      darkMode: p.getBool(_kDark) ?? false,
    );
  }

  Future<void> saveSettings(AppSettings s) async {
    final p = await _p;
    await p.setInt(_kPointsPerSet, s.pointsPerSet);
    await p.setBool(_kTieBreak, s.tieBreakTo15);
    await p.setInt(_kDecidingPoints, s.decidingSetPoints);
    await p.setBool(_kSound, s.soundEnabled);
    await p.setBool(_kDark, s.darkMode);
  }
}
