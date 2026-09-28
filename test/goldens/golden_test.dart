// Screenshots compared pixel by pixel. After an intentional visual change,
// regenerate them on macOS with:
//   flutter test --update-goldens --tags golden
// and review the PNG diff in the pull request.
@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/game/cards.dart';
import 'package:masmus/services/match_store.dart';
import 'package:masmus/ui/cards/playing_card_view.dart';
import 'package:masmus/ui/start/new_match_screen.dart';
import 'package:masmus/ui/start/start_screen.dart';
import 'package:masmus/ui/table/end_view.dart';
import 'package:masmus/ui/theme/app_theme.dart';
import 'package:masmus/ui/widgets/action_button.dart';
import 'package:masmus/ui/widgets/felt.dart';
import 'package:masmus/ui/widgets/lance_chip.dart';
import 'package:masmus/ui/widgets/score_board.dart';
import 'package:masmus/ui/widgets/speech_bubble.dart';
import 'package:masmus/ui/widgets/table_chip.dart';

import '../helpers/devices.dart';
import '../helpers/table.dart';
import '../helpers/test_app.dart';

/// The narrowest iPhone the app supports and the most common one.
final _devices = {
  'iphone_se': testDevices.firstWhere((d) => d.name == 'iPhone SE (3rd gen)'),
  'iphone_pro': testDevices.firstWhere((d) => d.name == 'iPhone 16 Pro'),
};

/// Every base component of the Tapete design system (#19), laid out roughly
/// where the table puts them.
Widget _components() => Scaffold(
  body: Felt(
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          spacing: AppSpacing.lg,
          children: [
            const ScoreBoard(
              usLabel: 'Nosotros',
              us: 12,
              themLabel: 'Ellos',
              them: 20,
            ),
            const Row(
              spacing: AppSpacing.xs,
              children: [
                Expanded(
                  child: LanceChip(
                    lance: 'Mus',
                    status: 'cortado',
                    state: LanceChipState.done,
                  ),
                ),
                Expanded(
                  child: LanceChip(
                    lance: 'Grande',
                    status: 'te toca',
                    state: LanceChipState.current,
                  ),
                ),
                Expanded(
                  child: LanceChip(
                    lance: 'Chica',
                    state: LanceChipState.pending,
                  ),
                ),
                Expanded(
                  child: LanceChip(
                    lance: 'Pares',
                    state: LanceChipState.pending,
                  ),
                ),
                Expanded(
                  child: LanceChip(
                    lance: 'Juego',
                    state: LanceChipState.pending,
                  ),
                ),
              ],
            ),
            const Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                SpeechBubble('No hay mus'),
                SpeechBubble('Envido 2'),
                SpeechBubble('Paso'),
              ],
            ),
            const Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                TableChip('Mano', highlighted: true),
                TableChip('Duples R-7'),
                TableChip('Juego 34'),
              ],
            ),
            const Spacer(),
            Row(
              spacing: AppSpacing.sm,
              children: [
                Expanded(
                  child: ActionButton(label: 'Paso', onPressed: () {}),
                ),
                Expanded(
                  flex: 2,
                  child: ActionButton(
                    label: 'Envido',
                    detail: '2',
                    kind: ActionKind.primary,
                    onPressed: () {},
                  ),
                ),
                Expanded(
                  child: ActionButton(
                    label: 'Órdago',
                    detail: 'mantén',
                    kind: ActionKind.ordago,
                    onPressed: () {},
                  ),
                ),
              ],
            ),
            const Row(
              children: [
                Expanded(
                  child: ActionButton(label: 'Descartar', onPressed: null),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  ),
);

/// The 40 faces and the back, at [width].
Widget _deck(double width) => ColoredBox(
  color: AppColors.felt,
  child: Padding(
    padding: const EdgeInsets.all(AppSpacing.sm),
    child: Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final suit in Suit.values)
          for (final number in cardNumbers)
            PlayingCardView(PlayingCard(suit, number), width: width),
        PlayingCardView(
          const PlayingCard(Suit.oros, 1),
          width: width,
          faceUp: false,
        ),
      ],
    ),
  ),
);

/// A card face up, marked to be thrown away and face down.
Widget _cardStates() => ColoredBox(
  color: AppColors.felt,
  child: Center(
    child: Row(
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpacing.lg,
      children: [
        PlayingCardView(PlayingCard.parse('Rc'), onTap: () {}),
        PlayingCardView(PlayingCard.parse('Rc'), selected: true, onTap: () {}),
        PlayingCardView(PlayingCard.parse('Rc'), faceUp: false),
      ],
    ),
  ),
);

/// Captures [child] on a surface of [size] logical pixels at 2x.
Future<void> _capture(
  WidgetTester tester,
  Widget child,
  Size size,
  String name,
) async {
  tester.view
    ..physicalSize = size * 2
    ..devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(buildTestApp(child));
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('goldens/$name.png'),
  );
}

/// Screens, by the name of their golden.
final Map<String, Widget Function()> _screens = {
  'start': () => StartScreen(
    store: MatchStore.inMemory(),
    table: (partner, rules) => const SizedBox(),
    resume: (_) => const SizedBox(),
  ),
  'start_saved': () => StartScreen(
    store: MatchStore.inMemory(savedMatch()),
    table: (partner, rules) => const SizedBox(),
    resume: (_) => const SizedBox(),
  ),
  'new_match': () => NewMatchScreen(onStart: (partner, rules) {}),
  for (final MapEntry(key: moment, value: controller) in tableMoments.entries)
    'table_$moment': () => tableScreen(controller()),
  for (final MapEntry(key: moment, value: controller) in countMoments.entries)
    moment: () => tableScreen(controller()),
  for (final MapEntry(key: moment, value: controller) in endMoments.entries)
    moment: () => EndView(
      match: controller().match,
      you: 0,
      onRematch: () {},
      onHome: () {},
    ),
};

void main() {
  _devices.forEach((deviceName, device) {
    _screens.forEach((screenName, screen) {
      testWidgets('$screenName on $deviceName', (tester) async {
        device.apply(tester);
        await tester.pumpWidget(
          buildTestApp(screen(), platform: device.platform),
        );
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/$screenName.$deviceName.png'),
        );
      });
    });
  });

  testWidgets('the deck at the size of a hand', (tester) async {
    await _capture(tester, _deck(88), const Size(968, 716), 'deck');
  });

  testWidgets('the deck at the size of the count', (tester) async {
    await _capture(tester, _deck(52), const Size(608, 442), 'deck_compact');
  });

  testWidgets('the states of a card', (tester) async {
    await _capture(tester, _cardStates(), const Size(360, 200), 'card_states');
  });

  _devices.forEach((deviceName, device) {
    testWidgets('components on $deviceName', (tester) async {
      device.apply(tester);
      await tester.pumpWidget(
        buildTestApp(_components(), platform: device.platform),
      );
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/components.$deviceName.png'),
      );
    });
  });
}
