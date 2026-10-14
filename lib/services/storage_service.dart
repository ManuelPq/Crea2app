import 'package:shared_preferences/shared_preferences.dart';

import '../models/match_record.dart';

/// Persistencia local de partidos y ajustes usando SharedPreferences.
class StorageService {
  static const _kMatches = 'matches_v2';
  static const _kType = 'default_type';
  static const _kTargetPoints = 'default_target_points';
  static const _kSwitchEvery = 'default_switch_every';
  static const _kDecidingPoints = 'default_deciding_points';
  static const _kSound = 'sound_enabled';
  static const _kDark = 'dark_mode';
  static const _kColorA = 'team_color_a';
  static const _kColorB = 'team_color_b';

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
      defaultType: MatchType.values.firstWhere(
        (t) => t.name == p.getString(_kType),
        orElse: () => MatchType.single,
      ),
      defaultTargetPoints: p.getInt(_kTargetPoints) ?? 21,
      defaultSwitchEvery: p.getInt(_kSwitchEvery) ?? 7,
      defaultDecidingPoints: p.getInt(_kDecidingPoints) ?? 15,
      soundEnabled: p.getBool(_kSound) ?? true,
      darkMode: p.getBool(_kDark) ?? false,
      defaultColorA: p.getInt(_kColorA) ?? 0xFFE53935,
      defaultColorB: p.getInt(_kColorB) ?? 0xFF1E6FEB,
    );
  }

  Future<void> saveSettings(AppSettings s) async {
    final p = await _p;
    await p.setString(_kType, s.defaultType.name);
    await p.setInt(_kTargetPoints, s.defaultTargetPoints);
    await p.setInt(_kSwitchEvery, s.defaultSwitchEvery);
    await p.setInt(_kDecidingPoints, s.defaultDecidingPoints);
    await p.setBool(_kSound, s.soundEnabled);
    await p.setBool(_kDark, s.darkMode);
    await p.setInt(_kColorA, s.defaultColorA);
    await p.setInt(_kColorB, s.defaultColorB);
  }
}
