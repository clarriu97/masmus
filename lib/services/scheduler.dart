import 'dart:async';

/// Runs an action after a delay and returns a function that cancels it. The
/// app uses timers; tests use [ManualScheduler] and move time themselves.
abstract interface class Scheduler {
  factory Scheduler() = _TimerScheduler;

  void Function() after(Duration delay, void Function() action);
}

final class _TimerScheduler implements Scheduler {
  @override
  void Function() after(Duration delay, void Function() action) =>
      Timer(delay, action).cancel;
}

/// A scheduler whose clock only moves when [advance] is called.
final class ManualScheduler implements Scheduler {
  final _tasks = <({Duration at, void Function() action})>[];
  var _now = Duration.zero;

  /// Every delay asked for, in order.
  final requested = <Duration>[];

  bool get hasPending => _tasks.isNotEmpty;

  @override
  void Function() after(Duration delay, void Function() action) {
    requested.add(delay);
    final task = (at: _now + delay, action: action);
    _tasks.add(task);
    return () => _tasks.remove(task);
  }

  /// Moves the clock forward by [by], running every task that falls due, in
  /// order, including tasks those tasks schedule.
  void advance(Duration by) {
    final until = _now + by;
    while (true) {
      final due = _tasks.where((task) => task.at <= until).toList()
        ..sort((a, b) => a.at.compareTo(b.at));
      if (due.isEmpty) {
        break;
      }
      final next = due.first;
      _tasks.remove(next);
      _now = next.at;
      next.action();
    }
    _now = until;
  }
}
