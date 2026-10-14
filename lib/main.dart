import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'models/match_record.dart';
import 'providers/matches_provider.dart';
import 'providers/scoreboard_provider.dart';
import 'screens/home_screen.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // La app arranca en horizontal (marcador). Historial y Ajustes permiten girar.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  final storage = StorageService();
  final settings = await storage.loadSettings();

  runApp(VoleyScoreApp(storage: storage, initialSettings: settings));
}

class VoleyScoreApp extends StatelessWidget {
  const VoleyScoreApp({
    super.key,
    required this.storage,
    required this.initialSettings,
  });

  final StorageService storage;
  final AppSettings initialSettings;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storage),
        ChangeNotifierProvider(create: (_) => MatchesProvider(storage)..load()),
        ChangeNotifierProvider(
          create: (_) => ScoreboardProvider()..applySettings(initialSettings),
        ),
      ],
      child: Consumer<ScoreboardProvider>(
        builder: (context, score, _) {
          return MaterialApp(
            title: 'Voley Score',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: score.settings.darkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
