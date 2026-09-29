import 'package:flutter/material.dart';

import '../../game/cards.dart';
import '../../l10n/app_localizations.dart';
import '../cards/playing_card_view.dart';
import '../theme/app_theme.dart';
import '../widgets/speech_bubble.dart';

/// A bot at the table: who it is, its four cards face down and what it just
/// said, which pops up as it says it. While it is thinking, it is edged in
/// brass and its bubble is three dots.
class Seat extends StatelessWidget {
  const Seat({
    required this.name,
    required this.role,
    required this.thinking,
    this.said,
    this.saidAt,
    this.asked,
    super.key,
  });

  final String name;
  final String role;
  final bool thinking;
  final String? said;

  /// Where in the hand it was said: a new place, a new word.
  final int? saidAt;

  /// How many cards it asked for in the last discards, in words.
  final String? asked;

  static const _back = PlayingCard(Suit.oros, 1);

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final said = this.said;
    final thinking = this.thinking
        ? AppLocalizations.of(context).seatThinking
        : null;
    return Semantics(
      container: true,
      label: [name, role, ?asked, ?thinking ?? said].join('. '),
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: ShapeDecoration(
                shape: CircleBorder(
                  side: thinking != null
                      ? const BorderSide(color: AppColors.turn, width: 3)
                      : BorderSide.none,
                ),
                color: AppColors.avatar,
              ),
              child: SizedBox.square(
                dimension: 46,
                child: Center(
                  child: Text(
                    name.split(' ').last.characters.first,
                    style: text.headlineSmall?.copyWith(
                      color: AppColors.onAvatar,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(name, style: text.titleSmall, textAlign: TextAlign.center),
            Text(role, style: text.labelSmall, textAlign: TextAlign.center),
            if (asked case final asked?)
              Text(asked, style: text.labelSmall, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xs),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < 4; i++)
                  Align(
                    widthFactor: i == 3 ? 1 : 0.55,
                    child: const PlayingCardView(
                      _back,
                      width: 22,
                      faceUp: false,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (thinking != null)
              const ThinkingBubble()
            else
              Visibility.maintain(
                visible: said != null,
                child: PopIn(
                  key: ValueKey(saidAt),
                  child: SpeechBubble(said ?? ' '),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
