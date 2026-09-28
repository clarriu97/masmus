import 'dart:math';

import 'package:flutter/material.dart';

import '../../bots/heuristic_bot.dart';
import '../../bots/strategic_bot.dart';
import '../../controllers/match_controller.dart';
import '../../game/match.dart';
import '../../game/rules.dart';
import '../../services/match_store.dart';
import '../../services/scheduler.dart';
import 'table_screen.dart';

/// A new match against the bots: your [partner] across the table and two
/// rivals picked at random among the other personalities.
class TablePage extends StatefulWidget {
  const TablePage({
    required this.partner,
    required this.rules,
    this.seed,
    this.scheduler,
    this.store,
    super.key,
  });

  final Personality partner;
  final Rules rules;

  /// Decides the deal and the rivals; random when null.
  final int? seed;

  final Scheduler? scheduler;
  final MatchStore? store;

  @override
  State<TablePage> createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  late final Map<int, Personality> _bots;
  late final MatchController _controller;

  @override
  void initState() {
    super.initState();
    final seed = widget.seed ?? Random().nextInt(1 << 32);
    final random = Random(seed);
    final rivals = [
      for (final personality in Personality.values)
        if (personality != widget.partner) personality,
    ]..shuffle(random);
    _bots = {1: rivals[0], 2: widget.partner, 3: rivals[1]};
    _controller = MatchController(
      match: MatchState.start(seed: seed, rules: widget.rules),
      bots: {
        for (final MapEntry(key: seat, value: personality) in _bots.entries)
          seat: StrategicBot(personality, Random(seed + seat)),
      },
      scheduler: widget.scheduler ?? Scheduler(),
      store: widget.store ?? MatchStore.inMemory(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TableScreen(
    controller: _controller,
    bots: _bots,
    onExit: () => Navigator.of(context).maybePop(),
  );
}
