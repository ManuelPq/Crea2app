import 'package:flutter/material.dart';

import 'history_screen.dart';
import 'score_screen.dart';
import 'settings_screen.dart';
import '../widgets/app_drawer.dart';

/// Contenedor principal. Usa un menú lateral (hamburguesa) en vez de una
/// barra inferior, para aprovechar el poco alto disponible en horizontal.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _index = 1; // 0 = inicio/setup, 1 = historial, 2 = ajustes

  void _openMenu() => _scaffoldKey.currentState?.openDrawer();
  void _goTo(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final screens = [
      ScoreScreen(onOpenMenu: _openMenu, onOpenHistory: () => _goTo(1)),
      HistoryScreen(onOpenMenu: _openMenu),
      SettingsScreen(onOpenMenu: _openMenu),
    ];

    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(currentIndex: _index, onSelect: _goTo),
      body: IndexedStack(index: _index, children: screens),
    );
  }
}
