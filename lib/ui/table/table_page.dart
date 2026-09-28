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

/// A match against the bots: your [partner] across the table and two rivals
/// picked at random among the other personalities, and a rematch with the
/// same ones when it is over.
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
  late int _seed;
  late final Map<int, Personality> _bots;
  late MatchController _controller;

  @override
  void initState() {
    super.initState();
    _seed = widget.seed ?? Random().nextInt(1 << 32);
    final rivals = [
      for (final personality in Personality.values)
        if (personality != widget.partner) personality,
    ]..shuffle(Random(_seed));
    _bots = {1: rivals[0], 2: widget.partner, 3: rivals[1]};
    _controller = _start();
  }

  MatchController _start() => MatchController(
    match: MatchState.start(seed: _seed, rules: widget.rules),
    bots: {
      for (final MapEntry(key: seat, value: personality) in _bots.entries)
        seat: StrategicBot(personality, Random(_seed + seat)),
    },
    scheduler: widget.scheduler ?? Scheduler(),
    store: widget.store ?? MatchStore.inMemory(),
  );

  /// Another match: the same bots in the same seats and the same rules,
  /// a new deal.
  void _rematch() => setState(() {
    _controller.dispose();
    _seed++;
    _controller = _start();
  });

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TableScreen(
    key: ObjectKey(_controller),
    controller: _controller,
    bots: _bots,
    onExit: () => Navigator.of(context).maybePop(),
    onRematch: _rematch,
  );
}
