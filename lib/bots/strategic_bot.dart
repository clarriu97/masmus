import 'dart:math';

import '../game/cards.dart';
import '../game/event.dart';
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
  StrategicBot(this.personality, this._random, {this.readsSenas = true});

  /// Reads what its partner tells with its señas. Off only to measure what
  /// they are worth.
  final bool readsSenas;

  /// The advantage, in points en paso, that makes a hand worth playing as it
  /// is. The mano, who wins ties, needs a little less.
  static const cutAt = 0.0;
  static const manoBonus = 0.4;

  /// How much a rival's envite says about their hand: the chance of winning
  /// is discounted by this much for every envite of theirs in the lance.
  static const betSignal = 0.12;

  /// A raise over our own envite says more than an envite: the rival heard
  /// ours and went further. Its read is discounted by this much more.
  static const raiseSignal = 0.1;

  /// Whatever the odds, nobody pays to see with less than this read: an
  /// envite with this at the most, and a raise over our own envite with
  /// [raisedFloor]. Below it, refuse, or a bluffer may raise again.
  static const callFloor = 0.3;
  static const raisedFloor = 0.4;

  /// Envites a team says at most in a lance: the first and one raise.
  /// After that it only accepts, refuses or goes to órdago.
  static const maxEnvites = 2;

  /// Every way of discarding is tried on [screenDeals] deals; the best
  /// [finalists] are tried again on [finalDeals] more before choosing.
  static const screenDeals = 60;
  static const finalists = 3;
  static const finalDeals = 400;

  final Personality personality;
  final Random _random;

  @override
  Move choose(SeatView view) {
    final knowledge = Knowledge.of(view, senas: readsSenas);
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
    final chance = knowledge.winChance(
      lance,
      _random,
      samples: 80,
      partner: !_partnerRefused(view),
    );
    final envite = view.envite;
    return envite == null
        ? _open(view, lance, chance)
        : _answer(view, lance, chance, envite);
  }

  /// Bluffing into rivals who cut the mus rarely works: they like their
  /// cards. The careful personalities hold back the most.
  double _againstACut(SeatView view) =>
      Knowledge.of(view).rivalCut ? 1 - (1 - personality.bluffing) * 0.7 : 1;

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
        chance < 0.35 &&
        _random.nextDouble() < personality.bluffing * 0.22 * _againstACut(view);
    return bluffs ? const Envido(minEnvido) : const Paso();
  }

  Move _answer(SeatView view, Lance lance, double chance, Envite envite) {
    final envites = _envitesInLance(view);
    final team = teamOf(view.seat);
    final theirs = envites.where((seat) => teamOf(seat) != team).length;
    final ours = envites.length - theirs;
    final raisedOverUs = ours > 0 && theirs > 0;
    final read =
        (chance - betSignal * theirs - (raisedOverUs ? raiseSignal : 0)).clamp(
          0.0,
          1.0,
        );
    if (envite.ordago) {
      return read > _continuing(view, give: envite.noQuieroPoints)
          ? const Quiero()
          : const NoQuiero();
    }
    final boldness = personality.boldness;
    final canRaise = view.legal.contains(MoveKind.envido) && ours < maxEnvites;
    if (view.legal.contains(MoveKind.ordago) && read >= 0.9 && boldness > 0.6) {
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
    if (read > needed && read >= (raisedOverUs ? raisedFloor : callFloor)) {
      return const Quiero();
    }
    final bluffsAgain =
        canRaise &&
        raisedOverUs &&
        _random.nextDouble() < personality.bluffing * 0.15;
    return bluffsAgain ? const Envido(minEnvido) : const NoQuiero();
  }

  /// The partner said «no quiero» to the bet on the table and left the
  /// answer to this seat: its hand is no help in this lance.
  bool _partnerRefused(SeatView view) {
    final start = view.log.lastIndexWhere(
      (event) => event is EnvidoSaid || event is OrdagoSaid,
    );
    final partner = (view.seat + 2) % 4;
    return view.envite != null &&
        view.log
            .skip(start + 1)
            .any((event) => event is NoQuieroSaid && event.seat == partner);
  }

  /// Who said each envite of the lance being played, in order.
  List<int> _envitesInLance(SeatView view) {
    final start = view.log.lastIndexWhere((event) => event is LanceStarted);
    return [
      for (final event in view.log.skip(start + 1))
        if (event case EnvidoSaid(:final seat)) seat,
    ];
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
