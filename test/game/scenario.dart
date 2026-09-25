import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/game/cards.dart';
import 'package:masmus/game/event.dart';
import 'package:masmus/game/game_random.dart';
import 'package:masmus/game/hand_state.dart';
import 'package:masmus/game/move.dart';
import 'package:masmus/game/play.dart';
import 'package:masmus/game/rules.dart';
import 'package:masmus/game/table.dart';

import 'helpers.dart';

const mus = Mus();
const noHayMus = NoHayMus();
const paso = Paso();
const quiero = Quiero();
const noQuiero = NoQuiero();
const ordago = Ordago();

Envido envido(int amount) => Envido(amount);

Discard discard(String codes) => Discard(cards(codes));

/// The hands of each seat written by number, as in docs/RULES.md
/// (`{0: 'R R 7 1', …}`), with suits handed out across the whole table so no
/// card repeats.
Map<int, List<PlayingCard>> tableHands(Map<int, String> numbers) {
  final seen = <String, int>{};
  return {
    for (final MapEntry(:key, :value) in numbers.entries)
      key: [
        for (final number in value.split(' '))
          PlayingCard.parse(
            '$number${'oceb'[seen.update(number, (n) => n + 1, ifAbsent: () => 0)]}',
          ),
      ],
  };
}

/// A hand dealt from a stacked deck: [numbers] for each seat, then the rest
/// of the deck in its usual order as the stock.
HandState dealt(
  Map<int, String> numbers, {
  int mano = 0,
  bool musCorrido = false,
  Rules rules = const Rules(),
  int seed = 1,
}) {
  final hands = tableHands(numbers);
  final top = [for (final seat in speakingOrder(mano)) ...hands[seat]!];
  return HandState.deal(
    rules: rules,
    mano: mano,
    deck: [...top, ...spanishDeck.where((card) => !top.contains(card))],
    random: GameRandom(seed),
    musCorrido: musCorrido,
  );
}

/// Plays [moves] in order and checks that every state on the way survives
/// being saved as JSON and restored.
HandState run(HandState state, List<(int, Move)> moves) {
  expectSurvivesJson(state);
  var current = state;
  for (final (seat, move) in moves) {
    current = play(current, seat, move);
    expectSurvivesJson(current);
  }
  return current;
}

void expectSurvivesJson(HandState state) {
  final json = jsonDecode(jsonEncode(state.toJson())) as Map<String, Object?>;
  expect(HandState.fromJson(json).toJson(), state.toJson());
}

/// The events added to the log since [before].
List<GameEvent> since(HandState before, HandState after) =>
    after.log.sublist(before.log.length);
