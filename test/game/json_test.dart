import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/game/event.dart';
import 'package:masmus/game/hand_state.dart';
import 'package:masmus/game/hand_value.dart';
import 'package:masmus/game/outcome.dart';

void main() {
  test('an unknown event, outcome or phase in a save is a format error', () {
    expect(
      () => GameEvent.fromJson({'type': 'shrug', 'seat': 0}),
      throwsFormatException,
    );
    expect(
      () => LanceOutcome.fromJson({'type': 'shrug', 'lance': 'grande'}),
      throwsFormatException,
    );
    expect(
      () => HandPhase.fromJson({'type': 'shrug', 'seat': 0}),
      throwsFormatException,
    );
  });

  test('equal events and outcomes have equal hash codes', () {
    const envido = EnvidoSaid(1, amount: 2, stake: 2);
    expect(GameEvent.fromJson(envido.toJson()), envido);
    expect(GameEvent.fromJson(envido.toJson()).hashCode, envido.hashCode);
    expect(
      const EnvidoSaid(1, amount: 2, stake: 2),
      isNot(const EnvidoSaid(1, amount: 2, stake: 4)),
    );
    const noQuerido = NoQuerido(Lance.chica, team: 0, points: 1);
    expect(LanceOutcome.fromJson(noQuerido.toJson()), noQuerido);
    expect(
      LanceOutcome.fromJson(noQuerido.toJson()).hashCode,
      noQuerido.hashCode,
    );
    expect(
      const NoQuerido(Lance.chica, team: 0, points: 1),
      isNot(const NoQuerido(Lance.grande, team: 0, points: 1)),
    );
  });
}
