class AiProfile {
  const AiProfile({
    required this.name,
    required this.boldness,
    required this.bluffing,
    this.avatarUrl,
  });

  final String name;

  /// Probability of accepting/proposing high bets (0.0 - 1.0)
  final double boldness;

  /// Probability of betting without good cards (0.0 - 1.0)
  final double bluffing;
  final String? avatarUrl;
}
