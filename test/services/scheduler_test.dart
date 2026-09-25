import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/services/scheduler.dart';

void main() {
  group('the app scheduler', () {
    testWidgets('runs the action once the delay has passed', (tester) async {
      var runs = 0;
      Scheduler().after(const Duration(milliseconds: 500), () => runs++);
      await tester.pump(const Duration(milliseconds: 499));
      expect(runs, 0);
      await tester.pump(const Duration(milliseconds: 1));
      expect(runs, 1);
    });

    testWidgets('never runs a cancelled action', (tester) async {
      var runs = 0;
      final cancel = Scheduler().after(
        const Duration(milliseconds: 500),
        () => runs++,
      );
      cancel();
      await tester.pump(const Duration(seconds: 1));
      expect(runs, 0);
    });
  });

  group('the manual scheduler', () {
    test('runs due tasks in order, including the ones they schedule', () {
      final scheduler = ManualScheduler();
      final ran = <String>[];
      scheduler
        ..after(const Duration(seconds: 2), () => ran.add('b'))
        ..after(const Duration(seconds: 1), () {
          ran.add('a');
          scheduler.after(
            const Duration(milliseconds: 500),
            () => ran.add('a2'),
          );
        });
      scheduler.advance(const Duration(milliseconds: 999));
      expect(ran, isEmpty);
      scheduler.advance(const Duration(seconds: 2));
      expect(ran, ['a', 'a2', 'b']);
      expect(scheduler.hasPending, isFalse);
      expect(scheduler.requested, const [
        Duration(seconds: 2),
        Duration(seconds: 1),
        Duration(milliseconds: 500),
      ]);
    });

    test('forgets cancelled tasks', () {
      final scheduler = ManualScheduler();
      var runs = 0;
      final cancel = scheduler.after(const Duration(seconds: 1), () => runs++);
      cancel();
      scheduler.advance(const Duration(seconds: 5));
      expect(runs, 0);
      expect(scheduler.hasPending, isFalse);
    });
  });
}
