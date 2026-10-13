import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/matches_provider.dart';
import '../theme/app_theme.dart';

/// Menú lateral (hamburguesa) que sustituye a la barra inferior,
/// para aprovechar al máximo el poco alto disponible en horizontal.
class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.currentIndex,
    required this.onSelect,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final trashCount = context.watch<MatchesProvider>().trashCount;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: dark ? AppColors.darkSurface : Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabecera
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
              decoration: const BoxDecoration(gradient: AppGradients.sunset),
              child: Row(
                children: [
                  Image.asset('assets/images/pelota.png', width: 56, height: 56),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Voley Score',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900)),
                      Text('Marcador de vóley playa',
                          style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _tile(context, 0, Icons.sports_volleyball, 'Marcador'),
            _tile(
              context,
              1,
              Icons.history,
              'Historial',
              badge: trashCount > 0 ? '$trashCount' : null,
            ),
            _tile(context, 2, Icons.settings, 'Ajustes'),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Gira el móvil a horizontal para jugar 🏐',
                style: TextStyle(
                  fontSize: 12,
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
      ),
    );
  }

  Widget _tile(BuildContext context, int index, IconData icon, String label,
      {String? badge}) {
    final selected = currentIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: ListTile(
        selected: selected,
        selectedTileColor: AppColors.sunsetOrange.withValues(alpha: 0.14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Icon(icon,
            color: selected ? AppColors.sunsetDeep : null),
        title: Text(label,
            style: TextStyle(
                fontWeight: selected ? FontWeight.w900 : FontWeight.w600)),
        trailing: badge != null
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.sunsetDeep,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(badge,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12)),
              )
            : null,
        onTap: () {
          Navigator.pop(context); // cerrar el drawer
          onSelect(index);
        },
      ),
    );
  }
}
