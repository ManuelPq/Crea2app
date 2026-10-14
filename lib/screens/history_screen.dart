import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/match_record.dart';
import '../providers/matches_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_menu.dart';

/// Historial de partidos + Papelera (para borrar tras el torneo).
/// Esta pantalla puede girarse a vertical.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({
    super.key,
    this.currentIndex = 1,
    this.onNewMatch,
    this.onOpenScoreboard,
    this.onOpenSettings,
  });

  final int currentIndex;
  final VoidCallback? onNewMatch;
  final VoidCallback? onOpenScoreboard;
  final VoidCallback? onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final matches = context.watch<MatchesProvider>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 52,
          titleSpacing: 16,
          automaticallyImplyLeading: false,
          title: const Text(
            'Historial de partidos',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
          actions: [
            AppMenuButton(
              currentIndex: currentIndex,
              onNewMatch: () => onNewMatch?.call(),
              onScoreboard: () => onOpenScoreboard?.call(),
              onHistory: () {},
              onSettings: () => onOpenSettings?.call(),
            ),
            const SizedBox(width: 8),
          ],
          bottom: TabBar(
            tabs: [
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.format_list_bulleted, size: 18),
                    const SizedBox(width: 6),
                    Text('Partidos (${matches.history.length})'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.delete_outline, size: 18),
                    const SizedBox(width: 6),
                    Text('Papelera (${matches.trash.length})'),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _MatchList(
              matches: matches.history,
              emptyText:
                  'Aún no hay partidos guardados.\n¡Juega uno y se guardará solo! 🏐',
              isTrash: false,
            ),
            _TrashView(),
          ],
        ),
      ),
    );
  }
}

class _MatchList extends StatelessWidget {
  const _MatchList({
    required this.matches,
    required this.emptyText,
    required this.isTrash,
  });

  final List<MatchRecord> matches;
  final String emptyText;
  final bool isTrash;

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.sports_volleyball,
                size: 64,
                color: AppColors.sunsetOrange.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                emptyText,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(14),
      itemCount: matches.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) =>
          _MatchCard(match: matches[i], isTrash: isTrash),
    );
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({required this.match, required this.isTrash});

  final MatchRecord match;
  final bool isTrash;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<MatchesProvider>();
    final dateFmt = DateFormat('dd/MM/yy · HH:mm');
    final isMulti = match.type == MatchType.bestOf3;

    final scoreText = isMulti ? match.setsScore : match.finalScore;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // Resultado destacado (izquierda)
            Container(
              width: 70,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                gradient: AppGradients.sunset,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Text(
                    scoreText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    isMulti ? 'sets' : 'puntos',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            // Información central, repartida horizontalmente
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${match.teamA}  vs  ${match.teamB}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.sunsetOrange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '🏆 ${match.winnerName}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.sunsetDeep,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          isMulti
                              ? match.setsDetail
                              : '${match.teamA} ${match.pointsA} - ${match.pointsB} ${match.teamB}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '⏱ ${_dur(match.duration)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        dateFmt.format(match.playedAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            // Acciones (derecha)
            if (!isTrash)
              IconButton(
                tooltip: 'Mover a la papelera',
                onPressed: () {
                  provider.moveToTrash(match.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Partido enviado a la papelera 🗑️'),
                    ),
                  );
                },
                icon: const Icon(Icons.delete_outline),
              )
            else ...[
              IconButton(
                tooltip: 'Restaurar',
                onPressed: () => provider.restore(match.id),
                icon: const Icon(Icons.restore),
              ),
              IconButton(
                tooltip: 'Eliminar definitivamente',
                onPressed: () => _confirmDelete(context, provider),
                icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    MatchesProvider provider,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar definitivamente'),
        content: Text(
          '¿Eliminar "${match.teamA} vs ${match.teamB}" para siempre?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok == true) provider.deleteForever(match.id);
  }

  String _dur(Duration d) {
    final mm = d.inMinutes.toString().padLeft(2, '0');
    final ss = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }
}

class _TrashView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final matches = context.watch<MatchesProvider>();
    final trash = matches.trash;

    if (trash.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.delete_outline,
              size: 64,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'La papelera está vacía',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${trash.length} partido(s) en la papelera.',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _confirmEmpty(context, matches),
                icon: const Icon(Icons.delete_sweep, color: Colors.red),
                label: const Text(
                  'Vaciar papelera',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _MatchList(matches: trash, emptyText: '', isTrash: true),
        ),
      ],
    );
  }

  Future<void> _confirmEmpty(
    BuildContext context,
    MatchesProvider provider,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Vaciar papelera'),
        content: const Text(
          'Se eliminarán todos los partidos de la papelera de forma permanente. ¿Continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Vaciar'),
          ),
        ],
      ),
    );
    if (ok == true) provider.emptyTrash();
  }
}
