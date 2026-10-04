import 'dart:math';

import 'package:flutter/material.dart';

import '../../bots/heuristic_bot.dart';
import '../../bots/strategic_bot.dart';
import '../../controllers/match_controller.dart';
import '../../game/match.dart';
import '../../game/rules.dart';
import '../../services/match_store.dart';
import '../../services/scheduler.dart';
import '../../services/sounds.dart';
import 'table_screen.dart';

/// A match against the bots: your [partner] across the table and two
/// [rivals], chosen or picked at random among the other personalities, or a [saved] one resumed
/// where it was left; and a rematch with the same bots when it is over.
class TablePage extends StatefulWidget {
  const TablePage({
    required Personality this.partner,
    required Rules this.rules,
    this.rivals,
    this.pace = Pace.normal,
    this.handHelp = true,
    this.haptics = true,
    this.sounds,
    this.seed,
    this.scheduler,
    this.store,
    super.key,
  }) : saved = null;

  const TablePage.resume(
    SavedMatch this.saved, {
    this.pace = Pace.normal,
    this.handHelp = true,
    this.haptics = true,
    this.sounds,
    this.scheduler,
    this.store,
    super.key,
  }) : partner = null,
       rules = null,
       rivals = null,
       seed = null;

  /// How long the bots take to move.
  final Pace pace;

  /// Whether the table says what your hand is worth.
  final bool handHelp;

  /// Whether the phone vibrates when your turn comes.
  final bool haptics;

  /// What plays the table's sounds; none when they are off.
  final Sounds? sounds;

  final Personality? partner;
  final Rules? rules;

  /// The two rivals, right and left of you; random among the others when
  /// null.
  final List<Personality>? rivals;
  final SavedMatch? saved;

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
    final saved = widget.saved;
    if (saved != null) {
      _bots = saved.bots;
      _controller = _play(saved.match, deal: false);
      return;
    }
    final partner = widget.partner!;
    final rivals =
        widget.rivals ??
        ([
          for (final personality in Personality.values)
            if (personality != partner) personality,
        ]..shuffle(Random(_seed)));
    _bots = {1: rivals[0], 2: partner, 3: rivals[1]};
    _controller = _play(MatchState.start(seed: _seed, rules: widget.rules!));
  }

  /// A new match starts with its deal on the table; a saved one resumes
  /// with the cards already dealt.
  MatchController _play(MatchState match, {bool deal = true}) =>
      MatchController(
        match: match,
        bots: {
          for (final MapEntry(key: seat, value: personality) in _bots.entries)
            seat: StrategicBot(personality, Random(_seed + seat)),
        },
        seats: _bots,
        scheduler: widget.scheduler ?? Scheduler(),
        store: widget.store ?? MatchStore.inMemory(),
        pace: widget.pace,
        deal: deal,
      );

  /// Another match: the same bots in the same seats and the same rules,
  /// a new deal.
  void _rematch() => setState(() {
    final rules = _controller.match.rules;
    _controller.dispose();
    _seed++;
    _controller = _play(MatchState.start(seed: _seed, rules: rules));
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
    handHelp: widget.handHelp,
    haptics: widget.haptics,
    sounds: widget.sounds,
  );
}
