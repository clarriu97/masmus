import 'dart:convert';

import 'hand_value.dart';
import 'outcome.dart';

/// Something every player at the table sees happen. The hand keeps them in
/// order: what the table shows and what bots remember come from here.
sealed class GameEvent {
  const GameEvent();

  factory GameEvent.fromJson(Map<String, Object?> json) {
    int seat() => json['seat']! as int;
    return switch (json['type']) {
      'musSaid' => MusSaid(seat()),
      'noHayMusSaid' => NoHayMusSaid(seat()),
      'manoMoved' => ManoMoved(seat()),
      'discarded' => Discarded(seat(), count: json['count']! as int),
      'reshuffled' => const Reshuffled(),
      'lanceStarted' => LanceStarted(
        Lance.values.byName(json['lance']! as String),
        seats: (json['seats']! as List<Object?>).cast<int>(),
      ),
      'declared' => Declared(
        seat(),
        lance: Lance.values.byName(json['lance']! as String),
        has: json['has']! as bool,
      ),
      'pasoSaid' => PasoSaid(seat()),
      'envidoSaid' => EnvidoSaid(
        seat(),
        amount: json['amount']! as int,
        stake: json['stake']! as int,
      ),
      'quieroSaid' => QuieroSaid(seat()),
      'noQuieroSaid' => NoQuieroSaid(
        seat(),
        partnerDecides: json['partnerDecides']! as bool,
      ),
      'ordagoSaid' => OrdagoSaid(seat()),
      'lanceClosed' => LanceClosed(
        LanceOutcome.fromJson(json['outcome']! as Map<String, Object?>),
      ),
      'handEnded' => const HandEnded(),
      final type => throw FormatException('Unknown event', type),
    };
  }

  String get type;

  Map<String, Object?> toJson() => {'type': type};

  @override
  bool operator ==(Object other) =>
      other is GameEvent && jsonEncode(other.toJson()) == toString();

  @override
  int get hashCode => toString().hashCode;

  @override
  String toString() => jsonEncode(toJson());
}

abstract final class _SeatEvent extends GameEvent {
  const _SeatEvent(this.seat);

  final int seat;

  @override
  Map<String, Object?> toJson() => {...super.toJson(), 'seat': seat};
}

final class MusSaid extends _SeatEvent {
  const MusSaid(super.seat);

  @override
  String get type => 'musSaid';
}

final class NoHayMusSaid extends _SeatEvent {
  const NoHayMusSaid(super.seat);

  @override
  String get type => 'noHayMusSaid';
}

/// During mus corrido the mano moves on after every round of mus, and the
/// player who cuts it becomes mano (R-MUS-5).
final class ManoMoved extends _SeatEvent {
  const ManoMoved(super.seat);

  @override
  String get type => 'manoMoved';
}

final class Discarded extends _SeatEvent {
  const Discarded(super.seat, {required this.count});

  final int count;

  @override
  String get type => 'discarded';

  @override
  Map<String, Object?> toJson() => {...super.toJson(), 'count': count};
}

/// The stock ran out and the discards became the new one (R-MUS-4).
final class Reshuffled extends GameEvent {
  const Reshuffled();

  @override
  String get type => 'reshuffled';
}

/// A lance begins; [seats] are the players who can speak in it, in order.
final class LanceStarted extends GameEvent {
  const LanceStarted(this.lance, {required this.seats});

  final Lance lance;
  final List<int> seats;

  @override
  String get type => 'lanceStarted';

  @override
  Map<String, Object?> toJson() => {
    ...super.toJson(),
    'lance': lance.name,
    'seats': seats,
  };
}

/// A player says whether they have pares or juego (R-DEC-1, R-DEC-3).
final class Declared extends _SeatEvent {
  const Declared(super.seat, {required this.lance, required this.has});

  final Lance lance;
  final bool has;

  @override
  String get type => 'declared';

  @override
  Map<String, Object?> toJson() => {
    ...super.toJson(),
    'lance': lance.name,
    'has': has,
  };
}

final class PasoSaid extends _SeatEvent {
  const PasoSaid(super.seat);

  @override
  String get type => 'pasoSaid';
}

/// An envite or a raise of [amount]; [stake] is what is on the table now.
final class EnvidoSaid extends _SeatEvent {
  const EnvidoSaid(super.seat, {required this.amount, required this.stake});

  final int amount;
  final int stake;

  @override
  String get type => 'envidoSaid';

  @override
  Map<String, Object?> toJson() => {
    ...super.toJson(),
    'amount': amount,
    'stake': stake,
  };
}

final class QuieroSaid extends _SeatEvent {
  const QuieroSaid(super.seat);

  @override
  String get type => 'quieroSaid';
}

/// With [partnerDecides], the player's partner still answers (R-ENV-3).
final class NoQuieroSaid extends _SeatEvent {
  const NoQuieroSaid(super.seat, {required this.partnerDecides});

  final bool partnerDecides;

  @override
  String get type => 'noQuieroSaid';

  @override
  Map<String, Object?> toJson() => {
    ...super.toJson(),
    'partnerDecides': partnerDecides,
  };
}

final class OrdagoSaid extends _SeatEvent {
  const OrdagoSaid(super.seat);

  @override
  String get type => 'ordagoSaid';
}

final class LanceClosed extends GameEvent {
  const LanceClosed(this.outcome);

  final LanceOutcome outcome;

  @override
  String get type => 'lanceClosed';

  @override
  Map<String, Object?> toJson() => {
    ...super.toJson(),
    'outcome': outcome.toJson(),
  };
}

/// No more lances: the last one closed or an órdago was accepted.
final class HandEnded extends GameEvent {
  const HandEnded();

  @override
  String get type => 'handEnded';
}
