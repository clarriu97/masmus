import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../bots/heuristic_bot.dart';
import '../../game/senas.dart';
import 'face_painter.dart';

/// A bot's face at the table, alive: it blinks and glances around at its
/// own pace, looks up while it thinks, moves its mouth when it speaks and
/// makes each new seña with its gesture, one after another. Still with
/// reduced motion, where the seña is read in words instead.
class BotFace extends StatefulWidget {
  const BotFace({
    required this.personality,
    this.thinking = false,
    this.spoke,
    this.senas = const [],
    this.size = 56,
    super.key,
  });

  final Personality personality;
  final bool thinking;

  /// Changes whenever it says something new.
  final Object? spoke;

  /// The señas it has made this hand; new ones are acted out.
  final List<Sena> senas;

  final double size;

  /// How long each seña's gesture is held.
  static const senaHold = Duration(milliseconds: 1500);

  @override
  State<BotFace> createState() => _BotFaceState();
}

class _BotFaceState extends State<BotFace> with SingleTickerProviderStateMixin {
  late final _random = Random(widget.personality.index);
  late final _talk = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );
  Timer? _idle;
  Timer? _gesture;
  var _blink = false;
  var _gaze = Offset.zero;
  final _pending = <Sena>[];
  Sena? _sena;
  var _shown = 0;

  bool get _still => MediaQuery.disableAnimationsOf(context);

  @override
  void initState() {
    super.initState();
    _shown = widget.senas.length;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_still) {
      _idle?.cancel();
      _idle = null;
    } else {
      _idle ??= _later(_idling);
    }
  }

  @override
  void didUpdateWidget(BotFace old) {
    super.didUpdateWidget(old);
    if (widget.spoke != old.spoke && widget.spoke != null && !_still) {
      unawaited(_talk.forward(from: 0));
    }
    final senas = widget.senas;
    if (senas.length < _shown) {
      _shown = 0;
    }
    if (senas.length > _shown) {
      _pending.addAll(senas.skip(_shown));
      _shown = senas.length;
      if (!_still && _gesture == null) {
        _nextGesture();
      }
    }
  }

  Timer _later(void Function() action) =>
      Timer(Duration(milliseconds: 1800 + _random.nextInt(2600)), action);

  void _idling() {
    if (!mounted) {
      return;
    }
    if (_random.nextDouble() < 0.6) {
      setState(() => _blink = true);
      _idle = Timer(const Duration(milliseconds: 140), () {
        if (mounted) {
          setState(() => _blink = false);
          _idle = _later(_idling);
        }
      });
      return;
    }
    setState(
      () => _gaze = _gaze == Offset.zero
          ? Offset(_random.nextBool() ? 0.9 : -0.9, _random.nextDouble() * 0.6)
          : Offset.zero,
    );
    _idle = _later(_idling);
  }

  void _nextGesture() {
    if (_pending.isEmpty) {
      setState(() => _sena = null);
      _gesture = null;
      return;
    }
    setState(() => _sena = _pending.removeAt(0));
    _gesture = Timer(BotFace.senaHold, () {
      if (mounted) {
        _nextGesture();
      }
    });
  }

  @override
  void dispose() {
    _idle?.cancel();
    _gesture?.cancel();
    _talk.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: AnimatedBuilder(
      animation: _talk,
      builder: (context, _) => CustomPaint(
        size: Size.square(widget.size),
        painter: FacePainter(
          widget.personality,
          FacePose(
            blink: _blink && _sena == null ? 1 : 0,
            gaze: _sena != null
                ? Offset.zero
                : widget.thinking
                ? const Offset(0.6, -1)
                : _gaze,
            talking: _talk.isAnimating ? sin(_talk.value * pi * 3).abs() : 0,
            sena: _sena,
          ),
        ),
      ),
    ),
  );
}
