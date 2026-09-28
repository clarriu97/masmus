import '../bots/heuristic_bot.dart';
import 'app_localizations.dart';

/// Names and descriptions of things the engine and the bots know only by an
/// id.
extension LocalizedNames on AppLocalizations {
  String personalityName(Personality personality) => switch (personality) {
    Personality.prudente => personalityPrudente,
    Personality.temeraria => personalityTemeraria,
    Personality.calculador => personalityCalculador,
    Personality.farolero => personalityFarolero,
  };

  String personalityStyle(Personality personality) => switch (personality) {
    Personality.prudente => personalityPrudenteStyle,
    Personality.temeraria => personalityTemerariaStyle,
    Personality.calculador => personalityCalculadorStyle,
    Personality.farolero => personalityFaroleroStyle,
  };
}
