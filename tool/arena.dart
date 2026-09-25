// Plays bots against each other and prints a Markdown report:
//
//   dart run tool/arena.dart [a] [b] [pairs]
//
// a and b: random, heuristic (El Calculador) or a personality (prudente,
// temeraria, calculador, farolero). Defaults: heuristic random 250. Each pair
// is two matches on the same deal with the teams swapped.
import 'dart:io';

import 'package:masmus/bots/arena.dart';
import 'package:masmus/bots/heuristic_bot.dart';
import 'package:masmus/bots/random_bot.dart';

final _bots = <String, BotFactory>{
  'random': RandomBot.new,
  'heuristic': (random) => HeuristicBot(Personality.calculador, random),
  'prudente': (random) => HeuristicBot(Personality.prudente, random),
  'temeraria': (random) => HeuristicBot(Personality.temeraria, random),
  'calculador': (random) => HeuristicBot(Personality.calculador, random),
  'farolero': (random) => HeuristicBot(Personality.farolero, random),
};

void main(List<String> args) {
  final a = args.isNotEmpty ? args[0] : 'heuristic';
  final b = args.length > 1 ? args[1] : 'random';
  final pairs = args.length > 2 ? int.parse(args[2]) : 250;
  if (!_bots.containsKey(a) || !_bots.containsKey(b)) {
    stderr.writeln('Bots: ${_bots.keys.join(', ')}');
    exit(64);
  }
  final result = playArena(a: _bots[a]!, b: _bots[b]!, pairs: pairs);
  final (low, high) = result.interval;
  String percent(double value) => '${(value * 100).toStringAsFixed(1)} %';
  String rate(Style style, int count) =>
      style.perHand(count).toStringAsFixed(2);
  String bluffShare(Style style) => style.envites + style.ordagos == 0
      ? '—'
      : percent(style.bluffs / (style.envites + style.ordagos));
  stdout.writeln(
    '''
### Bot arena: $a vs $b

${result.matches} matches ($pairs deals, each played from both sides).

| | $a | $b |
|---|---|---|
| Matches won | ${percent(result.winRateA)} (95 %: ${percent(low)}–${percent(high)}) | ${percent(1 - result.winRateA)} |
| Envites per hand | ${rate(result.a, result.a.envites)} | ${rate(result.b, result.b.envites)} |
| Órdagos per hand | ${rate(result.a, result.a.ordagos)} | ${rate(result.b, result.b.ordagos)} |
| Mus cut per hand | ${rate(result.a, result.a.cuts)} | ${rate(result.b, result.b.cuts)} |
| Bets without the best hand | ${bluffShare(result.a)} | ${bluffShare(result.b)} |''',
  );
}
