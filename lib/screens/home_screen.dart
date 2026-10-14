import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'history_screen.dart';
import 'score_screen.dart';
import 'settings_screen.dart';
import 'splash_screen.dart';

/// Contenedor principal.
///
/// - Muestra una pantalla de bienvenida (splash) con la pelota animada.
/// - Marcador / Nuevo partido: SIEMPRE en horizontal.
/// - Historial y Ajustes: se pueden girar a vertical.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _splash = true;
  int _index = 0; // 0 = marcador/setup, 1 = historial, 2 = ajustes
  int _newMatchSignal = 0; // incrementa para pedir "nuevo partido"

  @override
  void initState() {
    super.initState();
    _lockLandscape();
  }

  void _lockLandscape() {
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _allowAll() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  }

  void _goTo(int i) {
    setState(() => _index = i);
    // Solo el marcador obliga a horizontal.
    if (i == 0) {
      _lockLandscape();
    } else {
      _allowAll();
    }
  }

  void _nuevoPartido() {
    setState(() {
      _index = 0;
      _newMatchSignal++;
    });
    _lockLandscape();
  }

  void _finishSplash() {
    if (mounted) setState(() => _splash = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_splash) {
      return SplashScreen(onFinish: _finishSplash);
    }

    final screens = [
      ScoreScreen(
        currentIndex: _index,
        newMatchSignal: _newMatchSignal,
        onNewMatch: _nuevoPartido,
        onOpenScoreboard: () => _goTo(0),
        onOpenHistory: () => _goTo(1),
        onOpenSettings: () => _goTo(2),
      ),
      HistoryScreen(
        currentIndex: _index,
        onNewMatch: _nuevoPartido,
        onOpenScoreboard: () => _goTo(0),
        onOpenSettings: () => _goTo(2),
      ),
      SettingsScreen(
        currentIndex: _index,
        onNewMatch: _nuevoPartido,
        onOpenScoreboard: () => _goTo(0),
        onOpenHistory: () => _goTo(1),
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
    );
  }
}
