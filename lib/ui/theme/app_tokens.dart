import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

import 'app_colors.dart';

/// Spacing scale (logical pixels).
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

/// Corner radii. Buttons and chips are stadiums, like counters.
class AppRadii {
  AppRadii._();

  static const double sm = 6;
  static const double md = 10;
  static const double lg = 16;
}

/// Minimum size for anything tappable.
const double kMinTapTarget = 48;

/// Height of the player's action buttons, in the thumb zone.
const double kActionHeight = 56;

/// Cards and bubbles lift off the felt; nothing else casts a shadow.
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> raised = [
    BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: Offset(0, 2)),
  ];
}

/// Motion durations and easing. Anything non-essential falls back to a
/// static change when `MediaQuery.disableAnimations` is on.
class AppMotion {
  AppMotion._();

  static const Duration short = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration long = Duration(milliseconds: 600);
  static const Curve curve = Curves.easeOutCubic;
}
