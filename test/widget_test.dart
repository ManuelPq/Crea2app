import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:voley_score/models/match_record.dart';
import 'package:voley_score/providers/matches_provider.dart';
import 'package:voley_score/providers/scoreboard_provider.dart';
import 'package:voley_score/services/storage_service.dart';

void main() {
  testWidgets('El marcador muestra los equipos y permite sumar puntos',
      (WidgetTester tester) async {
    final storage = StorageService();
    final matches = MatchesProvider(storage);
    final score = ScoreboardProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<StorageService>.value(value: storage),
          ChangeNotifierProvider.value(value: matches),
          ChangeNotifierProvider.value(value: score),
        ],
        child: const MaterialApp(
          home: Scaffold(body: SizedBox()),
        ),
      ),
    );

    // Lógica básica del marcador
    score.setNames('Ana', 'Bea');
    expect(score.teamA, 'Ana');
    expect(score.teamB, 'Bea');

    score.addPoint('a');
    expect(score.pointsA, 1);
    score.undo();
    expect(score.pointsA, 0);
  });

  test('Un set se cierra al alcanzar el objetivo con 2 de ventaja', () {
    final score = ScoreboardProvider()
      ..applySettings(const AppSettings(pointsPerSet: 21, tieBreakTo15: true));
    for (int i = 0; i < 20; i++) {
      score.addPoint('a');
      score.addPoint('b');
    }
    // 20-20
    score.addPoint('a'); // 21-20
    expect(score.completedSets.isEmpty, true);
    score.addPoint('a'); // 22-20 -> set
    expect(score.completedSets.length, 1);
    expect(score.setsWonA, 1);
    expect(score.pointsA, 0);
  });
}
