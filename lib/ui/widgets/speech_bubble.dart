import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// What a player said, next to their seat: "No hay mus", "Envido 2", "Paso".
class SpeechBubble extends StatelessWidget {
  const SpeechBubble(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => _Bubble(child: Text(text));
}

/// A player thinking what to say: three dots that light up in turn for a
/// few seconds, or all at once with reduced motion. As tall as a bubble.
class ThinkingBubble extends StatefulWidget {
  const ThinkingBubble({super.key});

  static const beat = Duration(milliseconds: 900);

  /// Longer than any bot thinks; then the dots stay still.
  static const beats = 6;

  @override
  State<ThinkingBubble> createState() => _ThinkingBubbleState();
}

class _ThinkingBubbleState extends State<ThinkingBubble>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: ThinkingBubble.beat,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating && _controller.value == 0) {
      _controller.repeat(count: ThinkingBubble.beats);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _Bubble(
    child: AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final lit = (_controller.value * 3).floor();
        return Row(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.xs,
          children: [
            for (var i = 0; i < 3; i++)
              Opacity(
                opacity: !_controller.isAnimating || lit == i ? 1 : 0.35,
                child: const Text('•'),
              ),
          ],
        );
      },
    ),
  );
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AppColors.bubble,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      boxShadow: AppShadows.raised,
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs + 2,
      ),
      child: DefaultTextStyle.merge(
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.onBubble,
          fontWeight: FontWeight.w800,
        ),
        child: child,
      ),
    ),
  );
}

/// Shows [child] with a short pop the first time it is built with this
/// key: a word just said. At once with reduced motion.
class PopIn extends StatelessWidget {
  const PopIn({required this.child, super.key});

  /// The same tween on every build, so rebuilding doesn't pop it again.
  static final _tween = Tween<double>(begin: 0, end: 1);

  final Widget child;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: _tween,
    duration: MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : AppMotion.medium,
    curve: Curves.easeOutBack,
    builder: (context, shown, child) => Opacity(
      opacity: shown.clamp(0, 1),
      child: Transform.scale(scale: 0.7 + 0.3 * shown, child: child),
    ),
    child: child,
  );
}
