import 'dart:math';

import '../game/cards.dart';
import '../game/hand_value.dart';
import '../game/move.dart';
import '../game/rules.dart';
import 'bot.dart';

/// How a bot likes to play. The same bot plays every personality; only
/// these numbers change.
final class Personality {
  const Personality({
    required this.name,
    required this.boldness,
    required this.bluffing,
  });

  static const prudente = Personality(
    name: 'El Prudente',
    boldness: 0.2,
    bluffing: 0.1,
  );
  static const temeraria = Personality(
    name: 'La Temeraria',
    boldness: 0.9,
    bluffing: 0.8,
  );
  static const calculador = Personality(
    name: 'El Calculador',
    boldness: 0.5,
    bluffing: 0.3,
  );
  static const farolero = Personality(
    name: 'El Farolero',
    boldness: 0.7,
    bluffing: 0.95,
  );

  static const all = [prudente, temeraria, calculador, farolero];

  final String name;

  /// 0 to 1: how readily it bets and accepts.
  final double boldness;

  /// 0 to 1: how often it bets without the hand for it.
  final double bluffing;
}

/// Simple rules of thumb on the bot's own cards: cuts the mus with a good
/// hand, keeps kings, aces and pairs, bets and answers by how strong its hand
/// is for the lance. A stand-in until the bots of M4.
final class HeuristicBot implements Bot {
  HeuristicBot(this.personality, this._random);

  final Personality personality;
  final Random _random;

  @override
  Move choose(SeatView view) {
    final value = HandValue(view.cards, view.rules);
    final legal = view.legal;
    if (legal.contains(MoveKind.mus)) {
      return _cutsMus(value, isMano: view.mano == view.seat)
          ? const NoHayMus()
          : const Mus();
    }
    if (legal.contains(MoveKind.discard)) {
      return Discard(_discards(view.cards, view.rules.kings));
    }
    final strength =
        _strength(value, view.lance!) +
        (view.mano == view.seat && view.envite == null ? 0.1 : 0);
    final envite = view.envite;
    if (envite == null) {
      if (strength > 0.95 && personality.boldness > 0.7) {
        return const Ordago();
      }
      if (strength > 0.7 || _random.nextDouble() < personality.bluffing * 0.3) {
        return const Envido(minEnvido);
      }
      return const Paso();
    }
    if (envite.ordago) {
      return strength > 0.9 - personality.boldness * 0.2
          ? const Quiero()
          : const NoQuiero();
    }
    final threshold = 0.75 - personality.boldness * 0.35;
    if (strength > threshold + 0.2 &&
        personality.boldness > 0.5 &&
        legal.contains(MoveKind.envido)) {
      return const Envido(minEnvido);
    }
    return strength > threshold ? const Quiero() : const NoQuiero();
  }

  bool _cutsMus(HandValue value, {required bool isMano}) =>
      const [31, 32, 40].contains(value.points) ||
      value.pares == ParesKind.medias ||
      value.pares == ParesKind.duples ||
      (isMano && value.ranks.where((rank) => rank == 12).length >= 2);

  /// Keeps kings, aces and pairs; when all four are worth keeping, lets go
  /// of the lowest card that isn't part of a pair.
  List<PlayingCard> _discards(List<PlayingCard> cards, Kings kings) {
    int rankOf(PlayingCard card) => effectiveRank(card, kings);
    bool paired(PlayingCard card) =>
        cards.where((other) => rankOf(other) == rankOf(card)).length >= 2;
    final discard = [
      for (final card in cards)
        if (rankOf(card) != 12 && rankOf(card) != 1 && !paired(card)) card,
    ];
    if (discard.isNotEmpty) {
      return discard;
    }
    final singles = [
      for (final card in cards)
        if (!paired(card)) card,
    ];
    final pool = singles.isNotEmpty ? singles : cards;
    return [pool.reduce((a, b) => rankOf(a) <= rankOf(b) ? a : b)];
  }

  double _strength(HandValue value, Lance lance) {
    final ranks = value.ranks;
    return switch (lance) {
      Lance.grande => switch (ranks.where((rank) => rank == 12).length) {
        4 => 1,
        3 => 0.95,
        _ => ranks.fold(0, (sum, rank) => sum + rank) / 48,
      },
      Lance.chica => switch (ranks.where((rank) => rank == 1).length) {
        4 => 1,
        3 => 0.9,
        _ => 1 - ranks.fold(0, (sum, rank) => sum + rank) / 48,
      },
      Lance.pares => switch (value.pares) {
        ParesKind.duples => 0.9 + value.paresRanks.first / 120,
        ParesKind.medias => 0.7 + value.paresRanks.first / 120,
        ParesKind.par => 0.4 + value.paresRanks.first / 120,
        ParesKind.none => 0,
      },
      Lance.juego => switch (value.points) {
        31 => 1,
        32 => 0.95,
        40 => 0.9,
        _ when value.hasJuego => 0.6,
        _ => 0,
      },
      Lance.punto => value.points / 30,
    };
  }
}
