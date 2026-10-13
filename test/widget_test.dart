import 'package:flutter_test/flutter_test.dart';

import 'package:voley_score/models/match_record.dart';
import 'package:voley_score/providers/scoreboard_provider.dart';

void main() {
  test('Punto único: el partido termina a 21 con 2 de ventaja', () {
    final score = ScoreboardProvider()
      ..startMatch(const GameSetup(
        teamA: 'Ana',
        teamB: 'Bea',
        type: MatchType.single,
        targetPoints: 21,
        switchEvery: 7,
      ));

    // 20-20
    for (int i = 0; i < 20; i++) {
      score.addPoint('a');
      score.addPoint('b');
    }
    expect(score.pointsA, 20);
    expect(score.pointsB, 20);

    expect(score.addPoint('a'), PointEvent.none); // 21-20, no ganado aún
    expect(score.matchFinished, false);
    expect(score.addPoint('a'), PointEvent.matchWon); // 22-20 -> fin
    expect(score.matchFinished, true);
  });

  test('Cambio de pista cada 7 puntos', () {
    final score = ScoreboardProvider()
      ..startMatch(const GameSetup(
        type: MatchType.single,
        targetPoints: 21,
        switchEvery: 7,
      ));

    // Sumar puntos 'a' uno a uno: el cambio ocurre al llegar a 7, 14...
    PointEvent? at7;
    for (int i = 0; i < 7; i++) {
      at7 = score.addPoint('a');
    }
    expect(at7, PointEvent.courtSwitch);
    expect(score.nextSwitchAt, 14);
  });

  test('Deshacer revierte el último punto', () {
    final score = ScoreboardProvider()
      ..startMatch(const GameSetup(targetPoints: 21, switchEvery: 7));
    score.addPoint('b');
    expect(score.pointsB, 1);
    score.undo();
    expect(score.pointsB, 0);
  });
}
