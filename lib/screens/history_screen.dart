import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/match_record.dart';
import '../providers/matches_provider.dart';
import '../theme/app_theme.dart';

/// Historial de partidos + Papelera (para borrar tras el torneo).
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final matches = context.watch<MatchesProvider>();
    final dark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Historial de partidos',
              style: TextStyle(fontWeight: FontWeight.w800)),
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
              emptyText: 'Aún no hay partidos guardados.\n¡Juega uno y guárdalo! 🏐',
              dark: dark,
              isTrash: false,
            ),
            _TrashView(dark: dark),
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
    required this.dark,
    required this.isTrash,
  });

  final List<MatchRecord> matches;
  final String emptyText;
  final bool dark;
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
              Icon(Icons.sports_volleyball, size: 64,
                  color: AppColors.sunsetOrange.withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              Text(emptyText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(14),
      itemCount: matches.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) => _MatchCard(match: matches[i], isTrash: isTrash),
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
    final dateFmt = DateFormat('dd/MM/yyyy · HH:mm');
    final winner = match.winnerName;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Trofeo / estado
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: AppGradients.sunset,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isTrash ? Icons.delete_outline : Icons.emoji_events,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 14),
            // Info del partido
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
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.sunsetOrange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          match.setsScore,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppColors.sunsetDeep,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('🏆 Ganó: $winner',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    match.setsDetail,
                    style: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${dateFmt.format(match.playedAt)}   ·   ⏱ ${_dur(match.duration)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Acciones
            if (!isTrash) ...[
              IconButton(
                tooltip: 'Mover a la papelera',
                onPressed: () {
                  provider.moveToTrash(match.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Partido enviado a la papelera 🗑️')),
                  );
                },
                icon: const Icon(Icons.delete_outline),
              ),
            ] else ...[
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
      BuildContext context, MatchesProvider provider) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar definitivamente'),
        content: Text('¿Eliminar "${match.teamA} vs ${match.teamB}" para siempre?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
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
  const _TrashView({required this.dark});
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final matches = context.watch<MatchesProvider>();
    final trash = matches.trash;

    if (trash.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline, size: 64,
                color: Colors.grey.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            const Text('La papelera está vacía',
                style: TextStyle(fontSize: 16)),
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
                label: const Text('Vaciar papelera',
                    style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
        Expanded(
          child: _MatchList(
            matches: trash,
            emptyText: '',
            dark: dark,
            isTrash: true,
          ),
        ),
      ],
    );
  }

  Future<void> _confirmEmpty(
      BuildContext context, MatchesProvider provider) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Vaciar papelera'),
        content: const Text(
            'Se eliminarán todos los partidos de la papelera de forma permanente. ¿Continuar?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
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
