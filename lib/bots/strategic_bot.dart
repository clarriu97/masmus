import 'dart:math';

import '../game/cards.dart';
import '../game/hand_state.dart';
import '../game/hand_value.dart';
import '../game/move.dart';
import '../game/table.dart';
import 'bot.dart';
import 'estimate.dart';
import 'heuristic_bot.dart';

/// Decides from estimates instead of rules of thumb: deals the hands it
/// can't see at random, agreeing with what the table has said, and plays
/// what does best on average.
final class StrategicBot implements Bot {
  StrategicBot(this.personality, this._random);

  /// The advantage, in points en paso, that makes a hand worth playing as it
  /// is. The mano, who wins ties, needs a little less.
  static const cutAt = 0.0;
  static const manoBonus = 0.4;

  /// How much a rival's envite says about their hand: the chance of winning
  /// is discounted by this much before answering it.
  static const betSignal = 0.12;

  /// Every way of discarding is tried on [screenDeals] deals; the best
  /// [finalists] are tried again on [finalDeals] more before choosing.
  static const screenDeals = 60;
  static const finalists = 3;
  static const finalDeals = 400;

  final Personality personality;
  final Random _random;

  @override
  Move choose(SeatView view) {
    final knowledge = Knowledge.of(view);
    if (view.legal.contains(MoveKind.mus)) {
      final bonus = view.mano == view.seat ? manoBonus : 0;
      return knowledge.advantage(_random) + bonus >= cutAt
          ? const NoHayMus()
          : const Mus();
    }
    if (view.legal.contains(MoveKind.discard)) {
      return Discard(_bestDiscard(knowledge));
    }
    final lance = view.lance!;
    final chance = knowledge.winChance(lance, _random, samples: 80);
    final envite = view.envite;
    return envite == null
        ? _open(view, lance, chance)
        : _answer(view, lance, chance, envite);
  }

  /// Nobody has bet yet in this lance.
  Move _open(SeatView view, Lance lance, double chance) {
    final boldness = personality.boldness;
    final nearTheEnd =
        max(view.score[0], view.score[1]) >= view.rules.target - 10;
    if ((nearTheEnd && chance >= 0.95 - boldness * 0.05) ||
        (_continuing(view, give: 0) < 0.15 && chance >= 0.6)) {
      return const Ordago();
    }
    if (chance >= 0.64 - boldness * 0.1) {
      return const Envido(minEnvido);
    }
    final bluffs =
        chance < 0.35 && _random.nextDouble() < personality.bluffing * 0.22;
    return bluffs ? const Envido(minEnvido) : const Paso();
  }

  Move _answer(SeatView view, Lance lance, double chance, Envite envite) {
    final read = (chance - betSignal).clamp(0.0, 1.0);
    if (envite.ordago) {
      return read > _continuing(view, give: envite.noQuieroPoints)
          ? const Quiero()
          : const NoQuiero();
    }
    final boldness = personality.boldness;
    final canRaise = view.legal.contains(MoveKind.envido);
    if (canRaise && read >= 0.9 && boldness > 0.6) {
      return const Ordago();
    }
    if (canRaise && read >= 0.78 - boldness * 0.08) {
      return const Envido(minEnvido);
    }
    final partnerAnswers = envite.responders.length > 1;
    final stake = envite.stake.toDouble();
    final combinations = switch (lance) {
      Lance.pares => 2.0,
      Lance.juego => 4.0,
      _ => 0.0,
    };
    final breakEven =
        (stake - envite.noQuieroPoints) / (2 * stake + combinations);
    final needed = partnerAnswers
        ? max(breakEven, 0.5) - boldness * 0.1
        : breakEven - boldness * 0.08;
    return read > needed ? const Quiero() : const NoQuiero();
  }

  /// A rough chance of winning the match by carrying on after giving the
  /// rivals [give] points: even at even scores, better the further ahead.
  double _continuing(SeatView view, {required int give}) {
    final team = teamOf(view.seat);
    final lead = view.score[team] - (view.score[1 - team] + give);
    return (0.5 + lead / view.rules.target).clamp(0.05, 0.95);
  }

  /// Tries every way of throwing away 1 to 4 cards and keeps the one whose
  /// hand after drawing does best.
  List<PlayingCard> _bestDiscard(Knowledge knowledge) {
    final cards = knowledge.cards;
    final discards = [
      for (var mask = 1; mask < 16; mask++)
        [
          for (var i = 0; i < 4; i++)
            if (mask & (1 << i) != 0) cards[i],
        ],
    ];
    final screen = _deals(knowledge, screenDeals);
    final best = _ranked(knowledge, discards, screen).take(finalists).toList();
    return _ranked(knowledge, best, [
      ...screen,
      ..._deals(knowledge, finalDeals),
    ]).first;
  }

  List<List<PlayingCard>> _deals(Knowledge knowledge, int count) => [
    for (var i = 0; i < count; i++) [...knowledge.unseen]..shuffle(_random),
  ];

  List<List<PlayingCard>> _ranked(
    Knowledge knowledge,
    List<List<PlayingCard>> discards,
    List<List<PlayingCard>> deals,
  ) {
    final scores = {
      for (final discard in discards)
        discard: knowledge.advantageAfterDrawing([
          for (final card in knowledge.cards)
            if (!discard.contains(card)) card,
        ], deals),
    };
    return [...discards]..sort((a, b) => scores[b]!.compareTo(scores[a]!));
  }
}
