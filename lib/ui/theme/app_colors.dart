import 'package:flutter/painting.dart';

/// Tapete (docs/design/directions/): green felt, cream cards of the classic
/// Spanish deck, brass for whose turn it is and maroon for the órdago.
class AppColors {
  AppColors._();

  static const Color none = Color(0x00000000);

  static const Color felt = Color(0xFF174634);
  static const Color feltLight = Color(0xFF1F5A43);
  static const Color feltDark = Color(0xFF10362A);
  static const Color grainLight = Color(0x0FFFFFFF);
  static const Color grainDark = Color(0x14000000);

  static const Color ink = Color(0xFFF4EDD9);
  static const Color inkSecondary = Color(0xFFB7C9B8);
  static const Color line = Color(0x47F4EDD9);
  static const Color lineStrong = Color(0x73F4EDD9);
  static const Color chip = Color(0x21F4EDD9);

  static const Color turn = Color(0xFFE2B24A);
  static const Color onTurn = Color(0xFF1D2B22);

  static const Color primary = Color(0xFFF4EDD9);
  static const Color onPrimary = Color(0xFF173E2F);
  static const Color ordago = Color(0xFF8F1D17);
  static const Color onOrdago = Color(0xFFFBEEE2);
  static const Color ordagoFill = Color(0x40FBEEE2);

  static const Color bubble = Color(0xFFF4EDD9);
  static const Color onBubble = Color(0xFF1D2B22);

  static const Color avatar = Color(0xFFE9DFC3);
  static const Color onAvatar = felt;

  static const Color card = Color(0xFFF7EFDC);
  static const Color cardInk = Color(0xFF2A2723);
  static const Color cardInkSecondary = Color(0xFF736856);
  static const Color cardEdge = Color(0xFFD8C79F);
  static const Color cardBack = Color(0xFF7B1D17);
  static const Color cardBackStripe = Color(0xFF6A1813);
  static const Color cardBackEdge = Color(0xFFEFE4C6);

  static const Color oros = Color(0xFFC28A12);
  static const Color copas = Color(0xFFB1251D);
  static const Color espadas = Color(0xFF2C5787);
  static const Color bastos = Color(0xFF3D6A2C);
  static const Color espadasShine = Color(0xFF9FB9D6);
  static const Color bastosShade = Color(0xFF24401B);

  /// The bots' faces, drawn in the inks of the deck.
  static const Color skin = Color(0xFFE9BE95);
  static const Color skinShade = Color(0xFFD29C70);
  static const Color hairDark = Color(0xFF2B211B);
  static const Color hairBrown = Color(0xFF5B3B24);
  static const Color hairGrey = Color(0xFFA39A8D);
  static const Color lip = Color(0xFFA9473B);
  static const Color tongue = Color(0xFFDE7D78);

  static const Color stone = Color(0xFFEFE6CC);
  static const Color stoneShade = Color(0xFFC9BE9F);
  static const Color shadow = Color(0x40000000);
}
