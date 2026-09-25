import 'dart:convert';

import 'hand_value.dart';

/// How a lance ended. The points of the count come from it (R-REC-2 to
/// R-REC-5); only a "no quiero" pays at once (R-ENV-6).
sealed class LanceOutcome {
  const LanceOutcome(this.lance);

  factory LanceOutcome.fromJson(Map<String, Object?> json) {
    final lance = Lance.values.byName(json['lance']! as String);
    return switch (json['type']) {
      'notPlayed' => NotPlayed(lance),
      'sinDisputa' => SinDisputa(lance, team: json['team']! as int),
      'enPaso' => EnPaso(lance),
      'querido' => Querido(lance, stake: json['stake']! as int),
      'noQuerido' => NoQuerido(
        lance,
        team: json['team']! as int,
        points: json['points']! as int,
      ),
      'ordagoQuerido' => OrdagoQuerido(lance),
      final type => throw FormatException('Unknown outcome', type),
    };
  }

  final Lance lance;

  String get type;

  Map<String, Object?> toJson() => {'type': type, 'lance': lance.name};

  @override
  bool operator ==(Object other) =>
      other is LanceOutcome && jsonEncode(other.toJson()) == toString();

  @override
  int get hashCode => toString().hashCode;

  @override
  String toString() => jsonEncode(toJson());
}

/// Nobody had pares (R-DEC-2).
final class NotPlayed extends LanceOutcome {
  const NotPlayed(super.lance);

  @override
  String get type => 'notPlayed';
}

/// Only one [team] could play it: no bets, it is counted at the end.
final class SinDisputa extends LanceOutcome {
  const SinDisputa(super.lance, {required this.team});

  final int team;

  @override
  String get type => 'sinDisputa';

  @override
  Map<String, Object?> toJson() => {...super.toJson(), 'team': team};
}

final class EnPaso extends LanceOutcome {
  const EnPaso(super.lance);

  @override
  String get type => 'enPaso';
}

final class Querido extends LanceOutcome {
  const Querido(super.lance, {required this.stake});

  final int stake;

  @override
  String get type => 'querido';

  @override
  Map<String, Object?> toJson() => {...super.toJson(), 'stake': stake};
}

/// The [team] that made the last envite wins the lance and took [points] at
/// once.
final class NoQuerido extends LanceOutcome {
  const NoQuerido(super.lance, {required this.team, required this.points});

  final int team;
  final int points;

  @override
  String get type => 'noQuerido';

  @override
  Map<String, Object?> toJson() => {
    ...super.toJson(),
    'team': team,
    'points': points,
  };
}

/// Decides the match on the spot (R-FIN-3).
final class OrdagoQuerido extends LanceOutcome {
  const OrdagoQuerido(super.lance);

  @override
  String get type => 'ordagoQuerido';
}
