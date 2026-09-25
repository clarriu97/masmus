/// With eight kings the treses count as reyes and the doses as ases
/// (R-BAR-2).
enum Kings { eight, four }

/// The variant a match is played with. Defaults follow the rulebooks.
final class Rules {
  const Rules({this.kings = Kings.eight, this.target = 40})
    : assert(target == 40 || target == 30);

  factory Rules.fromJson(Map<String, Object?> json) => Rules(
    kings: Kings.values.byName(json['kings']! as String),
    target: json['target']! as int,
  );

  final Kings kings;

  /// Points a pair needs to win the match (R-FIN-1).
  final int target;

  Map<String, Object?> toJson() => {'kings': kings.name, 'target': target};
}
