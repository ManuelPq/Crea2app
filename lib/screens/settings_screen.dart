import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/match_record.dart';
import '../providers/scoreboard_provider.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

/// Ajustes del marcador: puntos por set, tie-break, sonido, modo oscuro.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final score = context.watch<ScoreboardProvider>();
    final s = score.settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('Formato del partido'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.flag, color: AppColors.sunsetDeep),
                  title: const Text('Puntos por set'),
                  subtitle: Text('Al mejor de 3 · sets a ${s.pointsPerSet}'),
                  trailing: _stepper(
                    value: s.pointsPerSet,
                    min: 5,
                    max: 30,
                    onChanged: (v) => _apply(
                      context,
                      s.copyWith(pointsPerSet: v),
                    ),
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary:
                      const Icon(Icons.emoji_events, color: AppColors.sunsetDeep),
                  title: const Text('Set decisivo más corto'),
                  subtitle: Text(
                      'El 3er set se juega a ${s.decidingSetPoints} puntos'),
                  value: s.tieBreakTo15,
                  onChanged: (v) =>
                      _apply(context, s.copyWith(tieBreakTo15: v)),
                ),
                if (s.tieBreakTo15) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.timer,
                        color: AppColors.sunsetDeep),
                    title: const Text('Puntos del set decisivo'),
                    trailing: _stepper(
                      value: s.decidingSetPoints,
                      min: 5,
                      max: 21,
                      onChanged: (v) => _apply(
                        context,
                        s.copyWith(decidingSetPoints: v),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),
          _section('Experiencia'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary:
                      const Icon(Icons.volume_up, color: AppColors.turquoise),
                  title: const Text('Sonidos y vibración'),
                  subtitle: const Text('Al sumar puntos y cerrar sets'),
                  value: s.soundEnabled,
                  onChanged: (v) =>
                      _apply(context, s.copyWith(soundEnabled: v)),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode,
                      color: AppColors.turquoise),
                  title: const Text('Modo oscuro'),
                  value: s.darkMode,
                  onChanged: (v) => _apply(context, s.copyWith(darkMode: v)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _section('Acerca de'),
          Card(
            child: const Column(
              children: [
                ListTile(
                  leading:
                      Icon(Icons.sports_volleyball, color: AppColors.sunsetDeep),
                  title: Text('Voley Score'),
                  subtitle: Text('Marcador de vóley playa · versión 2.0'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              'Hecho para jugar en horizontal, a pie de pista 🏐',
              style: TextStyle(
                color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(left: 6, bottom: 8),
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 12,
            letterSpacing: 1.2,
            color: AppColors.sunsetDeep,
          ),
        ),
      );

  Widget _stepper({
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: value > min ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Text('$value',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        IconButton(
          onPressed: value < max ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }

  Future<void> _apply(BuildContext context, AppSettings newSettings) async {
    final score = context.read<ScoreboardProvider>();
    final storage = context.read<StorageService>();
    score.applySettings(newSettings);
    await storage.saveSettings(newSettings);
  }
}
