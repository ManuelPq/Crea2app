import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/match_record.dart';
import '../providers/scoreboard_provider.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

/// Ajustes por defecto del marcador (se aplican al configurar cada partido).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final score = context.watch<ScoreboardProvider>();
    final s = score.settings;

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Ajustes', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('Valores por defecto del partido'),
          Text(
            'En vóley playa lo habitual es: 21 puntos y cambio de pista cada 7. '
            'Estos valores se cargan al crear un partido (puedes cambiarlos en cada uno).',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.style, color: AppColors.sunsetDeep),
                  title: const Text('Tipo de partido'),
                  subtitle: Text(s.defaultType.label),
                  trailing: SegmentedButton<MatchType>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                          value: MatchType.single, label: Text('Único')),
                      ButtonSegment(
                          value: MatchType.bestOf3, label: Text('Mejor de 3')),
                    ],
                    selected: {s.defaultType},
                    onSelectionChanged: (v) =>
                        _apply(context, s.copyWith(defaultType: v.first)),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.flag, color: AppColors.sunsetDeep),
                  title: const Text('Puntos para finalizar'),
                  subtitle: Text('Por defecto: ${s.defaultTargetPoints}'),
                  trailing: _stepper(
                    value: s.defaultTargetPoints,
                    min: 5,
                    max: 30,
                    onChanged: (v) =>
                        _apply(context, s.copyWith(defaultTargetPoints: v)),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.swap_horiz,
                      color: AppColors.sunsetDeep),
                  title: const Text('Cambio de pista cada'),
                  subtitle: Text(s.defaultSwitchEvery == 0
                      ? 'Sin cambios'
                      : 'Cada ${s.defaultSwitchEvery} puntos'),
                  trailing: _stepper(
                    value: s.defaultSwitchEvery,
                    min: 0,
                    max: 15,
                    onChanged: (v) =>
                        _apply(context, s.copyWith(defaultSwitchEvery: v)),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.timer, color: AppColors.sunsetDeep),
                  title: const Text('Set decisivo (mejor de 3)'),
                  subtitle: Text('A ${s.defaultDecidingPoints} puntos'),
                  trailing: _stepper(
                    value: s.defaultDecidingPoints,
                    min: 5,
                    max: 21,
                    onChanged: (v) =>
                        _apply(context, s.copyWith(defaultDecidingPoints: v)),
                  ),
                ),
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
                  subtitle: const Text('Al sumar puntos y cambio de pista'),
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
          const Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.sports_volleyball,
                      color: AppColors.sunsetDeep),
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
