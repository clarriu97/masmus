import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/bots/arena.dart';
import 'package:masmus/bots/heuristic_bot.dart';
import 'package:masmus/bots/random_bot.dart';

BotFactory _heuristic(Personality personality) =>
    (random) => HeuristicBot(personality, random);

void main() {
  group('the Wilson interval', () {
    test('matches known values', () {
      final (low, high) = wilson(50, 100);
      expect(low, closeTo(0.4038, 0.0005));
      expect(high, closeTo(0.5962, 0.0005));
    });

    test('stays inside 0–1 at the extremes', () {
      final (lowNone, highNone) = wilson(0, 10);
      expect(lowNone, 0);
      expect(highNone, closeTo(0.2775, 0.0005));
      final (lowAll, highAll) = wilson(10, 10);
      expect(lowAll, closeTo(0.7225, 0.0005));
      expect(highAll, 1);
    });
  });

  test('every deal is played from both sides', () {
    final result = playArena(a: RandomBot.new, b: RandomBot.new, pairs: 20);
    expect(result.matches, 40);
    expect(result.a.hands, result.b.hands);
  });

  test('identical bots win about half the time', () {
    final result = playArena(
      a: _heuristic(Personality.calculador),
      b: _heuristic(Personality.calculador),
      pairs: 150,
    );
    final (low, high) = result.interval;
    expect(low, lessThan(0.5));
    expect(high, greaterThan(0.5));
  });

  test('the heuristic bot clearly beats random play', () {
    final result = playArena(
      a: _heuristic(Personality.calculador),
      b: RandomBot.new,
      pairs: 250,
    );
    expect(result.interval.$1, greaterThan(0.6));
  });

  test('random bets come without the best hand about half the time, '
      'the heuristic bot bets with it more often', () {
    final result = playArena(
      a: _heuristic(Personality.calculador),
      b: RandomBot.new,
      pairs: 100,
    );
    double bluffShare(Style style) =>
        style.bluffs / (style.envites + style.ordagos);
    expect(bluffShare(result.b), inInclusiveRange(0.4, 0.6));
    expect(bluffShare(result.a), lessThan(bluffShare(result.b)));
    expect(result.a.ordagos, 0, reason: 'El Calculador never goes to órdago');
  });
}
