import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/ui/theme/app_theme.dart';
import 'package:masmus/ui/widgets/lance_chip.dart';

import '../../helpers/test_app.dart';

BoxDecoration _decoration(WidgetTester tester) =>
    tester
            .widget<DecoratedBox>(
              find.descendant(
                of: find.byType(LanceChip),
                matching: find.byType(DecoratedBox),
              ),
            )
            .decoration
        as BoxDecoration;

Color? _ink(WidgetTester tester, String text) =>
    tester.widget<Text>(find.text(text)).style?.color;

void main() {
  testWidgets('the lance being played is in brass and read as selected', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        const LanceChip(
          lance: 'Grande',
          status: 'te toca',
          state: LanceChipState.current,
        ),
      ),
    );
    expect(_decoration(tester).color, AppColors.turn);
    expect(_ink(tester, 'Grande'), AppColors.onTurn);
    expect(_ink(tester, 'te toca'), AppColors.onTurn);
    expect(
      tester.getSemantics(find.byType(LanceChip)),
      matchesSemantics(
        label: 'Grande\nte toca',
        isSelected: true,
        hasSelectedState: true,
      ),
    );
  });

  testWidgets('a lance already played says how it went', (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        const LanceChip(
          lance: 'Chica',
          status: 'no quiero · Ellos +1',
          state: LanceChipState.done,
        ),
      ),
    );
    expect(_decoration(tester).color, AppColors.chip);
    expect(find.text('no quiero · Ellos +1'), findsOneWidget);
  });

  testWidgets('a lance still to come is only outlined', (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        const LanceChip(lance: 'Juego', state: LanceChipState.pending),
      ),
    );
    final decoration = _decoration(tester);
    expect(decoration.color, isNull);
    expect(decoration.border, isNotNull);
    expect(_ink(tester, 'Juego'), AppColors.inkSecondary);
  });
}
