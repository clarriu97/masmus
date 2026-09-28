import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/ui/theme/app_theme.dart';
import 'package:masmus/ui/widgets/table_chip.dart';

import '../../helpers/test_app.dart';

Future<(Color?, Color?)> _colors(WidgetTester tester, TableChip chip) async {
  await tester.pumpWidget(buildTestApp(chip));
  final decoration =
      tester.widget<DecoratedBox>(find.byType(DecoratedBox).last).decoration
          as ShapeDecoration;
  return (
    decoration.color,
    tester.widget<Text>(find.text(chip.label)).style?.color,
  );
}

void main() {
  testWidgets('a plain fact sits on a faint chip', (tester) async {
    expect(await _colors(tester, const TableChip('Juego 34')), (
      AppColors.chip,
      AppColors.ink,
    ));
  });

  testWidgets('a highlighted one, like the mano, is in brass', (tester) async {
    expect(await _colors(tester, const TableChip('Mano', highlighted: true)), (
      AppColors.turn,
      AppColors.onTurn,
    ));
  });
}
