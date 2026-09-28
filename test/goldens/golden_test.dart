// Screenshots compared pixel by pixel. After an intentional visual change,
// regenerate them on macOS with:
//   flutter test --update-goldens --tags golden
// and review the PNG diff in the pull request.
@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/ui/theme/app_theme.dart';
import 'package:masmus/ui/widgets/action_button.dart';
import 'package:masmus/ui/widgets/felt.dart';
import 'package:masmus/ui/widgets/lance_chip.dart';
import 'package:masmus/ui/widgets/score_board.dart';
import 'package:masmus/ui/widgets/speech_bubble.dart';
import 'package:masmus/ui/widgets/table_chip.dart';

import '../helpers/devices.dart';
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

void main() {
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
