import 'package:flutter/material.dart';

import '../../game/cards.dart';
import '../cards/playing_card_view.dart';
import '../theme/app_theme.dart';
import '../widgets/speech_bubble.dart';

/// A bot at the table: who it is, its four cards face down and what it just
/// said. Edged in brass while it is thinking.
class Seat extends StatelessWidget {
  const Seat({
    required this.name,
    required this.role,
    required this.thinking,
    this.said,
    this.asked,
    super.key,
  });

  final String name;
  final String role;
  final bool thinking;
  final String? said;

  /// How many cards it asked for in the last discards, in words.
  final String? asked;

  static const _back = PlayingCard(Suit.oros, 1);

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final said = this.said;
    return Semantics(
      container: true,
      label: [name, role, ?asked, ?said].join('. '),
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: ShapeDecoration(
                shape: CircleBorder(
                  side: thinking
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
            Visibility.maintain(
              visible: said != null,
              child: SpeechBubble(said ?? ' '),
            ),
          ],
        ),
      ),
    );
  }
}
