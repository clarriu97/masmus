// The store screenshots and the Play feature graphic: the app's real screens
// on the felt, each under a headline. After a visual change, regenerate them
// on macOS and copy them, without alpha as the stores want, into fastlane/:
//   flutter test --update-goldens --tags golden test/goldens/store_test.dart
//   tool/store_images.sh
@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/bots/heuristic_bot.dart';
import 'package:masmus/controllers/settings_controller.dart';
import 'package:masmus/game/cards.dart';
import 'package:masmus/services/links.dart';
import 'package:masmus/services/match_store.dart';
import 'package:masmus/ui/cards/playing_card_view.dart';
import 'package:masmus/ui/faces/face_painter.dart';
import 'package:masmus/ui/help/how_to_play_screen.dart';
import 'package:masmus/ui/start/new_match_screen.dart';
import 'package:masmus/ui/start/start_screen.dart';
import 'package:masmus/ui/theme/app_theme.dart';
import 'package:masmus/ui/widgets/felt.dart';

import '../helpers/table.dart';
import '../helpers/test_app.dart';

/// The phone the screens are laid out on: an iPhone 16 Pro.
const _phone = Size(393, 852);
const _phoneInsets = EdgeInsets.only(top: 59, bottom: 34);

/// Where each store wants its screenshots, and their size in pixels.
final _stores = {
  'app_store': const Size(1320, 2868),
  'play': const Size(1080, 1920),
};

/// What each screenshot tells, in the order the stores show them.
final _shots = <(String, String, String, Widget Function())>[
  (
    '01_mesa',
    'Mus de verdad en el móvil',
    'Tú y tu compañero contra dos bots',
    () => tableScreen(tableMoments['chica_answer']!()),
  ),
  (
    '02_rivales',
    'Bots con personalidad',
    'Prudentes, temerarios, calculadores o faroleros',
    () => NewMatchScreen(onStart: (partner, rules, rivals) {}),
  ),
  (
    '03_envite',
    'Envida, quiere o lánzate al órdago',
    'Cada lance se lee de un vistazo',
    () => tableScreen(tableMoments['partner_decides']!()),
  ),
  (
    '04_recuento',
    'Todas las cartas a la vista',
    'Al final de cada mano, quién gana y con qué',
    () => tableScreen(countMoments['count_juego']!()),
  ),
  (
    '05_reglas',
    'Las reglas de los reglamentos',
    'Y la ayuda para aprenderlas, en la app',
    () => const HowToPlayScreen(),
  ),
  (
    '06_sin_conexion',
    'Sin conexión, sin cuentas',
    'Tus partidas no salen del móvil',
    () => StartScreen(
      links: RecordedLinks(),
      store: MatchStore.inMemory(savedMatch()),
      settings: SettingsController.inMemory(),
      table: (partner, rules, rivals) => const SizedBox(),
      resume: (_) => const SizedBox(),
    ),
  ),
];

/// A headline and its line on the felt, over the screen laid out as on a
/// phone, its foot running off the bottom edge.
class _Shot extends StatelessWidget {
  const _Shot({
    required this.headline,
    required this.line,
    required this.screen,
  });

  final String headline;
  final String line;
  final Widget screen;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Felt(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final phoneWidth = width * 0.78;
          final scale = phoneWidth / _phone.width;
          final top = width * 0.36;
          return Stack(
            children: [
              Positioned(
                left: width * 0.08,
                right: width * 0.08,
                top: width * 0.1,
                child: Column(
                  spacing: width * 0.02,
                  children: [
                    Text(
                      headline,
                      textAlign: TextAlign.center,
                      style: text.displayMedium?.copyWith(
                        fontSize: width * 0.075,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      line,
                      textAlign: TextAlign.center,
                      style: text.titleLarge?.copyWith(
                        fontSize: width * 0.042,
                        color: AppColors.inkSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: (width - phoneWidth) / 2,
                top: top,
                width: phoneWidth,
                height: _phone.height * scale,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(48 * scale),
                    border: Border.all(
                      color: AppColors.lineStrong,
                      width: 3 * scale,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 40,
                        offset: Offset(0, 16),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(46 * scale),
                    child: FittedBox(
                      child: SizedBox.fromSize(
                        size: _phone,
                        child: MediaQuery(
                          data: const MediaQueryData(
                            size: _phone,
                            devicePixelRatio: 3,
                            padding: _phoneInsets,
                            viewPadding: _phoneInsets,
                          ),
                          child: buildTestApp(
                            screen,
                            platform: TargetPlatform.iOS,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// The Play feature graphic: the name and its promise beside a hand of la
/// 31 and the four bots.
class _Feature extends StatelessWidget {
  const _Feature();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    const hand = [
      PlayingCard(Suit.oros, 12),
      PlayingCard(Suit.copas, 11),
      PlayingCard(Suit.espadas, 7),
      PlayingCard(Suit.bastos, 4),
    ];
    return Felt(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 48),
        child: Row(
          spacing: 48,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: [
                  Text(
                    'Más Mus',
                    style: text.displayMedium?.copyWith(fontSize: 72),
                  ),
                  Text(
                    'Tú y tu compañero contra dos bots,\ncon las reglas de siempre.',
                    style: text.titleLarge?.copyWith(
                      fontSize: 26,
                      color: AppColors.inkSecondary,
                    ),
                  ),
                  Row(
                    spacing: 12,
                    children: [
                      for (final personality in Personality.values)
                        ClipOval(
                          child: ColoredBox(
                            color: AppColors.avatar,
                            child: CustomPaint(
                              size: const Size.square(64),
                              painter: FacePainter(
                                personality,
                                const FacePose(),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 360,
              height: 300,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  for (final (i, card) in hand.indexed)
                    Transform.translate(
                      offset: Offset((i - 1.5) * 62, (i - 1.5).abs() * 10),
                      child: Transform.rotate(
                        angle: (i - 1.5) * 0.14,
                        child: PlayingCardView(card, width: 150),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _render(
  WidgetTester tester,
  Size pixels,
  Widget child,
  String path,
) async {
  const pixelRatio = 3.0;
  tester.view
    ..physicalSize = pixels
    ..devicePixelRatio = pixelRatio;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(buildTestApp(child));
  await tester.pumpAndSettle();
  await expectLater(find.byType(MaterialApp).first, matchesGoldenFile(path));
}

void main() {
  _stores.forEach((store, pixels) {
    for (final (name, headline, line, screen) in _shots) {
      testWidgets('$name for $store', (tester) async {
        await _render(
          tester,
          pixels,
          _Shot(headline: headline, line: line, screen: screen()),
          'goldens/store/$store/$name.png',
        );
      });
    }
  });

  testWidgets('the Play feature graphic', (tester) async {
    tester.view
      ..physicalSize = const Size(1024, 500)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(buildTestApp(const _Feature()));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/store/play/feature_graphic.png'),
    );
  });
}
