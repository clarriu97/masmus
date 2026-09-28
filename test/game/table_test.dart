import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/game/table.dart';

void main() {
  test('R-ORD-1 · two pairs, with partners facing each other', () {
    for (final seat in seats) {
      expect(teamOf((seat + 2) % 4), teamOf(seat));
      expect(teamOf(nextSeat(seat)), isNot(teamOf(seat)));
    }
  });
}
