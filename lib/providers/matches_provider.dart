import 'package:flutter/foundation.dart';

import '../models/match_record.dart';
import '../services/storage_service.dart';

/// Gestiona el historial de partidos y la papelera.
class MatchesProvider extends ChangeNotifier {
  MatchesProvider(this._storage);

  final StorageService _storage;
  final List<MatchRecord> _matches = [];

  List<MatchRecord> get all => List.unmodifiable(_matches);

  /// Partidos activos (no borrados), ordenados del más reciente al más antiguo.
  List<MatchRecord> get history {
    final list = _matches
        .where((m) => m.status == MatchStatus.finished)
        .toList();
    list.sort((a, b) => b.playedAt.compareTo(a.playedAt));
    return list;
  }

  /// Elementos en la papelera.
  List<MatchRecord> get trash {
    final list = _matches.where((m) => m.status == MatchStatus.trash).toList();
    list.sort((a, b) => b.playedAt.compareTo(a.playedAt));
    return list;
  }

  int get trashCount => trash.length;

  Future<void> load() async {
    final loaded = await _storage.loadMatches();
    _matches
      ..clear()
      ..addAll(loaded);
    notifyListeners();
  }

  Future<void> _persist() => _storage.saveMatches(_matches);

  Future<void> addMatch(MatchRecord m) async {
    _matches.add(m);
    notifyListeners();
    await _persist();
  }

  /// Mueve a la papelera.
  Future<void> moveToTrash(String id) async {
    final i = _matches.indexWhere((m) => m.id == id);
    if (i != -1) {
      _matches[i].status = MatchStatus.trash;
      notifyListeners();
      await _persist();
    }
  }

  /// Restaura desde la papelera.
  Future<void> restore(String id) async {
    final i = _matches.indexWhere((m) => m.id == id);
    if (i != -1) {
      _matches[i].status = MatchStatus.finished;
      notifyListeners();
      await _persist();
    }
  }

  /// Elimina definitivamente.
  Future<void> deleteForever(String id) async {
    _matches.removeWhere((m) => m.id == id);
    notifyListeners();
    await _persist();
  }

  /// Vacía toda la papelera.
  Future<void> emptyTrash() async {
    _matches.removeWhere((m) => m.status == MatchStatus.trash);
    notifyListeners();
    await _persist();
  }
}
