/// With eight kings the treses count as reyes and the doses as ases
/// (R-BAR-2).
enum Kings { eight, four }

/// The variant a match is played with. Defaults follow the rulebooks.
final class Rules {
  const Rules({this.kings = Kings.eight, this.target = 40, this.games = 1})
    : assert(target == 40 || target == 30),
      assert(games == 1 || games == 3 || games == 5);

  factory Rules.fromJson(Map<String, Object?> json) => Rules(
    kings: Kings.values.byName(json['kings']! as String),
    target: json['target']! as int,
    games: json['games'] as int? ?? 1,
  );

  final Kings kings;

  /// Points a pair needs to win a juego (R-FIN-1).
  final int target;

  /// The match is one juego, or the best of three or five (R-FIN-5).
  final int games;

  /// Juegos a pair needs to win the match.
  int get gamesToWin => games ~/ 2 + 1;

  Rules copyWith({Kings? kings, int? target, int? games}) => Rules(
    kings: kings ?? this.kings,
    target: target ?? this.target,
    games: games ?? this.games,
  );

  Map<String, Object?> toJson() => {
    'kings': kings.name,
    'target': target,
    'games': games,
  };
}
