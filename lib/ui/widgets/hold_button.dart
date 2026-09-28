import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The órdago button: it only goes off after being held for [holdFor], its
/// fill showing how long is left, so it can't be thrown by accident. A tap
/// shows [hint] above it, clear of the other buttons. Screen readers get it
/// as a long press.
class HoldButton extends StatefulWidget {
  const HoldButton({
    required this.label,
    required this.detail,
    required this.hint,
    required this.onHeld,
    this.holdFor = const Duration(milliseconds: 700),
    super.key,
  });

  final String label;
  final String detail;
  final String hint;
  final VoidCallback onHeld;
  final Duration holdFor;

  @override
  State<HoldButton> createState() => _HoldButtonState();
}

class _HoldButtonState extends State<HoldButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hold = AnimationController(
    vsync: this,
    duration: widget.holdFor,
  )..addStatusListener(_held);

  void _held(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _hold.reset();
      widget.onHeld();
    }
  }

  final _tooltip = GlobalKey<TooltipState>();

  void _release() {
    if (_hold.isAnimating) {
      _hold.reset();
      _tooltip.currentState?.ensureTooltipVisible();
    }
  }

  @override
  void dispose() {
    _hold.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: widget.label,
      hint: widget.detail,
      onLongPress: widget.onHeld,
      excludeSemantics: true,
      child: Tooltip(
        key: _tooltip,
        message: widget.hint,
        triggerMode: TooltipTriggerMode.manual,
        preferBelow: false,
        child: GestureDetector(
          onTapDown: (_) => _hold.forward(),
          onTapUp: (_) => _release(),
          onTapCancel: _hold.reset,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: kActionHeight,
              minWidth: kMinTapTarget,
            ),
            child: DecoratedBox(
              decoration: const ShapeDecoration(
                shape: StadiumBorder(),
                color: AppColors.ordago,
              ),
              child: ClipPath(
                clipper: const ShapeBorderClipper(shape: StadiumBorder()),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _hold,
                        builder: (context, _) => FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _hold.value,
                          child: const ColoredBox(color: AppColors.ordagoFill),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.label,
                            textAlign: TextAlign.center,
                            style: text.labelLarge?.copyWith(
                              color: AppColors.onOrdago,
                            ),
                          ),
                          Text(
                            widget.detail,
                            style: AppTheme.actionDetail.copyWith(
                              color: AppColors.onOrdago,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
