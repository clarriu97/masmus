import 'dart:math';

import 'package:flutter/material.dart';

import '../../bots/heuristic_bot.dart';
import '../../controllers/match_controller.dart';
import '../../game/cards.dart';
import '../../game/event.dart';
import '../../game/hand_state.dart';
import '../../game/move.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/localized_names.dart';
import '../cards/deck_view.dart';
import '../cards/playing_card_view.dart';
import '../help/how_to_play_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/felt.dart';
import '../widgets/lance_chip.dart';
import '../widgets/score_board.dart';
import '../widgets/speech_bubble.dart';
import '../widgets/table_chip.dart';
import 'count_view.dart';
import 'end_view.dart';
import 'hand_history.dart';
import 'seat.dart';
import 'table_actions.dart';
import 'table_texts.dart';
import 'table_view.dart';

/// The match being played, seen from your seat: the score, where the hand
/// is and how each lance went, who is mano and whose turn it is, what each
/// player just said and what is on the table, and your cards.
class TableScreen extends StatefulWidget {
  const TableScreen({
    required this.controller,
    required this.bots,
    required this.onExit,
    required this.onRematch,
    this.handHelp = true,
    super.key,
  });

  /// Whether it says what your hand is worth.
  final bool handHelp;

  final MatchController controller;

  /// Who plays every seat but yours.
  final Map<int, Personality> bots;

  final VoidCallback onExit;

  /// Another match with the same bots and rules, once this one is over.
  final VoidCallback onRematch;

  /// The table is a board, dense by nature: its text grows with the
  /// system's up to this much, and the cards are already large.
  static const maxTextScale = 1.3;

  @override
  State<TableScreen> createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreen>
    with SingleTickerProviderStateMixin {
  static const _back = PlayingCard(Suit.oros, 1);

  /// The cards you have marked to throw away.
  final _marked = <PlayingCard>{};

  /// The deal being drawn, and how far it has gone.
  Deal? _deal;
  late final _dealt = AnimationController(vsync: this);

  final _layer = GlobalKey();
  final _deck = GlobalKey();
  final _cards = [for (var seat = 0; seat < 4; seat++) GlobalKey()];

  /// Where the deck and each seat's cards were at the last frame.
  Rect? _deckRect;
  final _rows = <int, Rect>{};

  bool get _reducedMotion => MediaQuery.disableAnimationsOf(context);

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_dealIfDealing);
    _dealIfDealing();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_dealIfDealing);
    _dealt.dispose();
    super.dispose();
  }

  void _dealIfDealing() {
    final deal = widget.controller.dealing;
    if (deal == _deal) {
      return;
    }
    _deal = deal;
    if (deal != null) {
      _dealt
        ..duration = deal.duration
        ..forward(from: 0);
    }
  }

  /// How far the [k]th card of the deal has flown: 0 in the deck, 1 landed.
  double _flight(int k) {
    final deal = _deal;
    if (deal == null || _reducedMotion) {
      return 1;
    }
    final elapsed = deal.duration * _dealt.value;
    return ((elapsed - Deal.between * k).inMicroseconds /
            Deal.flight.inMicroseconds)
        .clamp(0, 1);
  }

  /// How many of [seat]'s [cards] have landed by now.
  int _landed(int seat, int cards) {
    final deal = _deal;
    if (deal == null) {
      return cards;
    }
    var flying = 0;
    for (final (k, dealt) in deal.seats.indexed) {
      if (dealt == seat && _flight(k) < 1) {
        flying++;
      }
    }
    return cards - flying;
  }

  void _measure() {
    final layer = _layer.currentContext?.findRenderObject();
    if (layer is! RenderBox || !layer.hasSize) {
      return;
    }
    Rect? rectOf(GlobalKey key) {
      final box = key.currentContext?.findRenderObject();
      if (box is! RenderBox || !box.hasSize || !box.attached) {
        return null;
      }
      return MatrixUtils.transformRect(
        box.getTransformTo(layer),
        Offset.zero & box.size,
      );
    }

    _deckRect = rectOf(_deck);
    for (final (seat, key) in _cards.indexed) {
      if (rectOf(key) case final rect?) {
        _rows[seat] = rect;
      }
    }
  }

  /// The last count has been seen: the end of the match comes next.
  var _counted = false;

  void _toggle(PlayingCard card) => setState(
    () => _marked.contains(card) ? _marked.remove(card) : _marked.add(card),
  );

  void _play(Move move) {
    _marked.clear();
    widget.controller.play(move);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([widget.controller, _dealt]),
    builder: (context, _) {
      final l10n = AppLocalizations.of(context);
      final controller = widget.controller;
      final bots = widget.bots;
      final you = controller.humanSeat!;
      final match = controller.match;
      final caughtUp = !controller.catchingUp;
      if (caughtUp && match.isOver && (_counted || match.count == null)) {
        return EndView(
          match: match,
          you: you,
          onRematch: widget.onRematch,
          onHome: widget.onExit,
        );
      }
      if (caughtUp && match.hand.phase is HandOver) {
        return CountView(
          match: match,
          you: you,
          names: {
            you: l10n.countYou,
            for (final MapEntry(key: seat, value: bot) in bots.entries)
              seat: l10n.personalityName(bot),
          },
          onNext: match.isOver
              ? () => setState(() => _counted = true)
              : controller.nextHand,
        );
      }
      final view = TableView.of(
        match,
        you: you,
        shown: controller.shown,
        dealing: controller.dealing != null,
      );
      if (!view.youDiscard) {
        _marked.clear();
      }
      if (_deal != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
      }
      final onTable = {
        for (final seat in [0, 1, 2, 3])
          seat: _landed(
            seat,
            seat == you ? view.cards.length : 4 - (view.thrown[seat] ?? 0),
          ),
      };
      return MediaQuery.withClampedTextScaling(
        maxScaleFactor: TableScreen.maxTextScale,
        child: Scaffold(
          body: Felt(
            child: SafeArea(
              child: Stack(
                key: _layer,
                children: [
                  Column(
                    children: [
                      _TopBar(
                        view: view,
                        onExit: widget.onExit,
                        onHistory: () => showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => HandHistory(
                            log: match.hand.log.sublist(0, controller.shown),
                            view: view,
                            names: {
                              you: l10n.countYou,
                              for (final MapEntry(key: seat, value: bot)
                                  in bots.entries)
                                seat: l10n.personalityName(bot),
                            },
                          ),
                        ),
                      ),
                      _Steps(view: view),
                      Expanded(
                        child: _Seats(
                          view: view,
                          bots: bots,
                          onTable: onTable,
                          cardsKeys: _cards,
                          deckKey: _deck,
                        ),
                      ),
                      _YourHand(
                        view: view,
                        help: widget.handHelp,
                        marked: _marked,
                        onTap: view.youDiscard ? _toggle : null,
                        onTable: onTable[you]!,
                        cardsKey: _cards[you],
                        deckKey: _deck,
                      ),
                      _Status(view: view, bots: bots),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          AppSpacing.sm,
                          AppSpacing.lg,
                          AppSpacing.sm,
                        ),
                        child: view.yourTurn && controller.humanMoves.isNotEmpty
                            ? TableActions(
                                key: ValueKey(controller.match.hand.phase),
                                moves: controller.humanMoves,
                                view: view,
                                bettor: switch (view.stake?.bettor) {
                                  final bettor? when bots.containsKey(bettor) =>
                                    l10n.personalityName(bots[bettor]!),
                                  _ => null,
                                },
                                marked: _marked.toList(),
                                onMove: _play,
                              )
                            : _TurnBar(view: view, bots: bots),
                      ),
                    ],
                  ),
                  ..._flying(you),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );

  /// The cards in the air, from the deck to whoever gets each.
  List<Widget> _flying(int you) {
    final deal = _deal;
    final deck = _deckRect;
    if (deal == null || deck == null || _reducedMotion) {
      return const [];
    }
    final yours = deal.seats.where((seat) => seat == you).length;
    var slot = 4 - yours;
    final flying = <Widget>[];
    for (final (k, seat) in deal.seats.indexed) {
      final t = _flight(k);
      final row = _rows[seat];
      if (t > 0 && t < 1 && row != null) {
        flying.add(
          _flyingCard(
            from: deck.center,
            to: seat == you ? _slotCenter(row, slot) : row.center,
            t: t,
            width: seat == you
                ? DeckView.cardWidth +
                      (_slotWidth(row) - DeckView.cardWidth) * t
                : DeckView.cardWidth,
          ),
        );
      }
      if (seat == you) {
        slot++;
      }
    }
    return flying;
  }

  Widget _flyingCard({
    required Offset from,
    required Offset to,
    required double t,
    required double width,
  }) {
    final at = Offset.lerp(from, to, Curves.easeOutCubic.transform(t))!;
    final height = width / PlayingCardView.aspectRatio;
    return Positioned(
      left: at.dx - width / 2,
      top: at.dy - height / 2,
      child: IgnorePointer(
        child: PlayingCardView(_back, width: width, faceUp: false),
      ),
    );
  }

  static double _slotWidth(Rect row) => (row.width - 3 * AppSpacing.sm) / 4;

  static Offset _slotCenter(Rect row, int slot) => Offset(
    row.left + slot * (_slotWidth(row) + AppSpacing.sm) + _slotWidth(row) / 2,
    row.center.dy,
  );
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.view,
    required this.onExit,
    required this.onHistory,
  });

  final TableView view;
  final VoidCallback onExit;
  final VoidCallback onHistory;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xs),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: onExit,
            icon: const Icon(Icons.close),
            label: Text(l10n.tableExit),
          ),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: ScoreBoard(
                usLabel: l10n.teamUs,
                us: view.us,
                themLabel: l10n.teamThem,
                them: view.them,
                dense: true,
              ),
            ),
          ),
          Text(
            l10n.tableTarget(view.target),
            style: Theme.of(context).textTheme.labelSmall,
          ),
          IconButton(
            tooltip: l10n.historyTitle,
            onPressed: onHistory,
            icon: const Icon(Icons.forum_outlined),
          ),
          IconButton(
            tooltip: l10n.howTitle,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const HowToPlayScreen()),
            ),
            icon: const Icon(Icons.help_outline),
          ),
        ],
      ),
    );
  }
}

/// The mus and the four lances, each with how it went.
class _Steps extends StatelessWidget {
  const _Steps({required this.view});

  final TableView view;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.xs,
          children: [
            for (final step in view.steps)
              Expanded(
                child: LanceChip(
                  lance: l10n.stepLabel(step),
                  status: l10n.stepStatus(step, view),
                  state: switch (step.state) {
                    StepProgress.pending => LanceChipState.pending,
                    StepProgress.current => LanceChipState.current,
                    StepProgress.done => LanceChipState.done,
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Your partner across the table, the rivals at the sides and what is bet
/// in the middle. On a short screen the three sit in a row, and the bet is
/// read in the row of the hand; scaled down if it still doesn't fit.
class _Seats extends StatelessWidget {
  const _Seats({
    required this.view,
    required this.bots,
    required this.onTable,
    required this.cardsKeys,
    required this.deckKey,
  });

  static const compactBelow = 260.0;

  final TableView view;
  final Map<int, Personality> bots;

  /// How many cards each seat holds on the table by now.
  final Map<int, int> onTable;

  final List<Key> cardsKeys;
  final Key deckKey;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Widget seatOf(int seat) => Seat(
      name: l10n.personalityName(bots[seat]!),
      role: l10n.seatRole(view, seat),
      thinking: view.turn == seat,
      asked: switch (view.asked[seat]) {
        final count? => l10n.seatAsked(count),
        null => null,
      },
      said: switch (view.said[seat]) {
        final event? => l10n.said(event, view),
        null => null,
      },
      saidAt: view.saidAt[seat],
      cards: onTable[seat]!,
      cardsKey: cardsKeys[seat],
      deckKey: deckKey,
      deck: seat != view.mano
          ? null
          : (seat - view.you) % 4 == 1
          ? AxisDirection.left
          : AxisDirection.right,
    );
    final you = view.you;
    return LayoutBuilder(
      builder: (context, constraints) => FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: constraints.maxWidth,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.md,
            ),
            child: constraints.maxHeight < compactBelow
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final seat in [you + 3, you + 2, you + 1])
                        Expanded(child: seatOf(seat % 4)),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: AppSpacing.md,
                    children: [
                      seatOf((you + 2) % 4),
                      Row(
                        children: [
                          Expanded(child: seatOf((you + 3) % 4)),
                          _Center(view: view),
                          Expanded(child: seatOf((you + 1) % 4)),
                        ],
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// In the middle of the table: the step being played and what is bet in
/// it, or how the lance that just closed went, while the table holds it.
class _Center extends StatelessWidget {
  const _Center({required this.view});

  static const _width = 104.0;

  final TableView view;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final value = l10n.centerValue(view);
    final number = int.tryParse(value) != null;
    return ExcludeSemantics(
      child: Container(
        width: _width,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: view.latest is LanceClosed || view.latest is NoHayMusSaid
                ? AppColors.turn
                : AppColors.line,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.center(view).toUpperCase(),
              style: text.labelSmall,
              textAlign: TextAlign.center,
            ),
            PopIn(
              key: ValueKey((view.latest, value)),
              child: Text(
                value,
                textAlign: TextAlign.center,
                style: number ? text.displaySmall : text.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Your cards, big, with what they are worth above them. While you
/// discard, a tap marks a card to throw away and the marked ones rise. New
/// cards come in with a short fade, or at once with reduced motion.
class _YourHand extends StatelessWidget {
  const _YourHand({
    required this.view,
    required this.help,
    required this.marked,
    required this.onTap,
    required this.onTable,
    required this.cardsKey,
    required this.deckKey,
  });

  final TableView view;
  final bool help;
  final Set<PlayingCard> marked;
  final ValueChanged<PlayingCard>? onTap;

  /// How many of your cards have been dealt to you by now.
  final int onTable;

  final Key cardsKey;
  final Key deckKey;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final onTap = this.onTap;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        spacing: AppSpacing.sm,
        children: [
          if (onTap != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: AppSpacing.sm,
              children: [
                if (view.mano == view.you) DeckView(key: deckKey),
                Flexible(child: Text(l10n.discardHint, style: text.bodySmall)),
              ],
            )
          else
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: AppSpacing.sm,
                    children: [
                      if (view.mano == view.you) DeckView(key: deckKey),
                      if (view.yourTurn)
                        PopIn(
                          child: TableChip(
                            l10n.tableYourTurn,
                            highlighted: true,
                          ),
                        )
                      else if (view.said[view.you] case final said?)
                        PopIn(
                          key: ValueKey(view.saidAt[view.you]),
                          child: SpeechBubble(l10n.said(said, view)),
                        ),
                      if (view.mano == view.you) TableChip(l10n.tableMano),
                    ],
                  ),
                ),
                if (help)
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      spacing: AppSpacing.sm,
                      children: [
                        for (final line in l10n.handHelp(view.value))
                          TableChip(line),
                      ],
                    ),
                  ),
              ],
            ),
          LayoutBuilder(
            builder: (context, constraints) {
              final byHeight =
                  MediaQuery.sizeOf(context).height *
                  0.155 *
                  PlayingCardView.aspectRatio;
              final width = [
                (constraints.maxWidth - 3 * AppSpacing.sm) / 4,
                byHeight,
                88.0,
              ].reduce(min);
              return Padding(
                padding: EdgeInsets.only(
                  top: onTap == null
                      ? 0
                      : width /
                            PlayingCardView.aspectRatio *
                            PlayingCardView.lift,
                ),
                child: Row(
                  key: cardsKey,
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: AppSpacing.sm,
                  children: [
                    for (final (i, card) in view.cards.indexed)
                      Visibility.maintain(
                        key: ValueKey(card),
                        visible: i < onTable,
                        child: PlayingCardView(
                          card,
                          width: width,
                          selected: marked.contains(card),
                          onTap: onTap == null ? null : () => onTap(card),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// What the table is at, for screen readers: the lance, whose turn it is
/// and what is bet. Announced whenever it changes.
class _Status extends StatelessWidget {
  const _Status({required this.view, required this.bots});

  final TableView view;
  final Map<int, Personality> bots;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final current = view.steps.firstWhere(
      (step) => step.state == StepProgress.current,
      orElse: () => view.steps.last,
    );
    final stake = view.bet;
    return Semantics(
      liveRegion: true,
      label: [
        l10n.stepLabel(current),
        ?_turnText(l10n, view, bots),
        l10n.tableStakeIs(switch (stake) {
          null => l10n.tableStakeNone,
          _ when stake.ordago => l10n.stepOrdago,
          _ => '${stake.stake}',
        }),
      ].join('. '),
      child: const SizedBox.shrink(),
    );
  }
}

String? _turnText(
  AppLocalizations l10n,
  TableView view,
  Map<int, Personality> bots,
) => switch (view.turn) {
  null => null,
  _ when view.yourTurn => l10n.tableYourTurn,
  final turn => l10n.tableTurnOf(l10n.personalityName(bots[turn]!)),
};

/// Whose turn it is, while it isn't yours; nothing while the table shows
/// what just happened.
class _TurnBar extends StatelessWidget {
  const _TurnBar({required this.view, required this.bots});

  final TableView view;
  final Map<int, Personality> bots;

  @override
  Widget build(BuildContext context) {
    final turn = _turnText(AppLocalizations.of(context), view, bots);
    return ExcludeSemantics(
      child: Container(
        constraints: const BoxConstraints(minHeight: kActionHeight),
        alignment: Alignment.center,
        decoration: turn == null
            ? null
            : const ShapeDecoration(
                shape: StadiumBorder(
                  side: BorderSide(color: AppColors.line, width: 1.5),
                ),
              ),
        child: Text(turn ?? '', style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}
