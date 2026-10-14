import 'package:flutter/material.dart';

/// Menú desplegable (☰) con la navegación principal.
/// Se coloca arriba a la DERECHA en todas las pantallas, sustituyendo al
/// antiguo menú lateral (drawer).
class AppMenuButton extends StatelessWidget {
  const AppMenuButton({
    super.key,
    required this.onNewMatch,
    required this.onScoreboard,
    required this.onHistory,
    required this.onSettings,
    this.currentIndex = 0,
  });

  final VoidCallback onNewMatch;
  final VoidCallback onScoreboard;
  final VoidCallback onHistory;
  final VoidCallback onSettings;

  /// 0 = marcador, 1 = historial, 2 = ajustes
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      alignmentOffset: const Offset(-172, 4),
      menuChildren: [
        _item(
          context,
          icon: Icons.add_circle_outline,
          label: 'Nuevo partido',
          onTap: onNewMatch,
        ),
        _item(
          context,
          icon: Icons.sports_volleyball,
          label: 'Marcador',
          onTap: onScoreboard,
          selected: currentIndex == 0,
        ),
        _item(
          context,
          icon: Icons.history,
          label: 'Historial',
          onTap: onHistory,
          selected: currentIndex == 1,
        ),
        _item(
          context,
          icon: Icons.settings,
          label: 'Ajustes',
          onTap: onSettings,
          selected: currentIndex == 2,
        ),
      ],
      builder: (context, controller, child) {
        return IconButton.filledTonal(
          tooltip: 'Menú',
          onPressed: () =>
              controller.isOpen ? controller.close() : controller.open(),
          icon: const Icon(Icons.menu),
        );
      },
    );
  }

  Widget _item(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool selected = false,
  }) {
    return MenuItemButton(
      onPressed: onTap,
      leadingIcon: Icon(
        icon,
        color: selected ? Theme.of(context).colorScheme.primary : null,
      ),
      child: SizedBox(
        width: 168,
        child: Text(
          label,
          style: TextStyle(
            fontWeight: selected ? FontWeight.w900 : FontWeight.w500,
            color: selected ? Theme.of(context).colorScheme.primary : null,
          ),
        ),
      ),
    );
  }
}
