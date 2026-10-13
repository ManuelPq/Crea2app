import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/matches_provider.dart';
import 'history_screen.dart';
import 'score_screen.dart';
import 'settings_screen.dart';

/// Contenedor principal con navegación inferior (Marcador / Historial / Ajustes).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final trashCount = context.watch<MatchesProvider>().trashCount;
    final screens = [
      const ScoreScreen(),
      const HistoryScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.sports_volleyball_outlined),
            selectedIcon: Icon(Icons.sports_volleyball),
            label: 'Marcador',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: trashCount > 0,
              label: Text('$trashCount'),
              child: const Icon(Icons.history_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: trashCount > 0,
              label: Text('$trashCount'),
              child: const Icon(Icons.history),
            ),
            label: 'Historial',
          ),
          const NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}
