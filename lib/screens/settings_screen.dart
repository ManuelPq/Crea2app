import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/match_record.dart';
import '../providers/scoreboard_provider.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_menu.dart';
import '../widgets/bouncing_ball.dart';

/// Ajustes por defecto del marcador (se aplican al configurar cada partido).
/// Cabecera compacta y disposición en 2 columnas para aprovechar el horizontal.
/// Esta pantalla puede girarse a vertical.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    this.currentIndex = 2,
    this.onNewMatch,
    this.onOpenScoreboard,
    this.onOpenHistory,
  });

  final int currentIndex;
  final VoidCallback? onNewMatch;
  final VoidCallback? onOpenScoreboard;
  final VoidCallback? onOpenHistory;

  @override
  Widget build(BuildContext context) {
    final score = context.watch<ScoreboardProvider>();
    final s = score.settings;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 52,
        titleSpacing: 16,
        automaticallyImplyLeading: false,
        title: const Text(
          'Ajustes',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        actions: [
          AppMenuButton(
            currentIndex: currentIndex,
            onNewMatch: () => onNewMatch?.call(),
            onScoreboard: () => onOpenScoreboard?.call(),
            onHistory: () => onOpenHistory?.call(),
            onSettings: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, c) {
          final columnas = c.maxWidth < 620;
          if (columnas) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 40),
              children: [
                _bloquePartido(context, s),
                const SizedBox(height: 14),
                _bloqueExperiencia(context, s),
                const SizedBox(height: 14),
                _bloqueAcerca(context),
              ],
            );
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      _bloquePartido(context, s),
                      const SizedBox(height: 16),
                      _bloqueAcerca(context),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ListView(
                    children: [
                      _bloqueExperiencia(context, s),
                      const SizedBox(height: 16),
                      _avisoHorizontal(context),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _bloquePartido(BuildContext context, AppSettings s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _section('Valores por defecto del partido'),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.style,
                          color: AppColors.sunsetDeep,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Tipo de partido'),
                              Text(
                                s.defaultType.label,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<MatchType>(
                        showSelectedIcon: false,
                        segments: const [
                          ButtonSegment(
                            value: MatchType.single,
                            label: Text('Único'),
                          ),
                          ButtonSegment(
                            value: MatchType.bestOf3,
                            label: Text('Mejor de 3'),
                          ),
                        ],
                        selected: {s.defaultType},
                        onSelectionChanged: (v) =>
                            _apply(context, s.copyWith(defaultType: v.first)),
                      ),
                    ),
                  ],
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
                leading: const Icon(
                  Icons.swap_horiz,
                  color: AppColors.sunsetDeep,
                ),
                title: const Text('Cambio de pista cada'),
                subtitle: Text(
                  s.defaultSwitchEvery == 0
                      ? 'Sin cambios'
                      : 'Cada ${s.defaultSwitchEvery} puntos',
                ),
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
        const SizedBox(height: 8),
        Text(
          'En vóley playa lo habitual es 21 puntos y cambio de pista cada 7. '
          'Estos valores se cargan al crear un partido (puedes cambiarlos en cada uno).',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }

  Widget _bloqueExperiencia(BuildContext context, AppSettings s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _section('Experiencia'),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              SwitchListTile(
                secondary: const Icon(
                  Icons.volume_up,
                  color: AppColors.turquoise,
                ),
                title: const Text('Sonidos y vibración'),
                subtitle: const Text('Al sumar puntos y cambio de pista'),
                value: s.soundEnabled,
                onChanged: (v) => _apply(context, s.copyWith(soundEnabled: v)),
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: const Icon(
                  Icons.dark_mode,
                  color: AppColors.turquoise,
                ),
                title: const Text('Modo oscuro'),
                value: s.darkMode,
                onChanged: (v) => _apply(context, s.copyWith(darkMode: v)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bloqueAcerca(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _section('Acerca de'),
        Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            onTap: () => _showAbout(context),
            leading: const Icon(
              Icons.sports_volleyball,
              color: AppColors.sunsetDeep,
            ),
            title: const Text('Voley Score'),
            subtitle: const Text('Marcador de vóley playa · versión 2.0'),
            trailing: const Icon(Icons.info_outline),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  void _showAbout(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BouncingBall(size: 130),
              const SizedBox(height: 16),
              const Text(
                'Voley Score',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              const Text(
                'Marcador de vóley playa · versión 2.0',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 18),
              const Text(
                'Pensado para jugar a pie de pista: marcador grande, '
                'cambio de pista automático cada 7 puntos e historial de '
                'partidos. Coloca el móvil en horizontal durante el partido.',
                textAlign: TextAlign.center,
                style: TextStyle(height: 1.4),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: const [
                  _Chip(icon: Icons.sports_volleyball, label: 'Vóley playa'),
                  _Chip(icon: Icons.timer, label: 'Cronómetro'),
                  _Chip(icon: Icons.history, label: 'Historial'),
                  _Chip(icon: Icons.swap_horiz, label: 'Cambio de pista'),
                ],
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _avisoHorizontal(BuildContext context) => Text(
    'Hecho para jugar en horizontal, a pie de pista 🏐',
    textAlign: TextAlign.center,
    style: TextStyle(
      fontSize: 12,
      color: Theme.of(
        context,
      ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
    ),
  );

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
          visualDensity: VisualDensity.compact,
          onPressed: value > min ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Text(
          '$value',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
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

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.sunsetOrange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.sunsetDeep),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
