import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/ui/theme/app_theme.dart';
import 'package:masmus/ui/widgets/choice_tile.dart';

import '../../helpers/test_app.dart';

Future<ShapeBorder?> _shape(
  WidgetTester tester, {
  required bool selected,
}) async {
  await tester.pumpWidget(
    buildTestComponent(
      ChoiceTile(
        title: 'El Farolero',
        subtitle: 'Envida sin nada cuando puede',
        selected: selected,
        onTap: () {},
      ),
    ),
  );
  return tester
      .widget<Material>(
        find.descendant(
          of: find.byType(ChoiceTile),
          matching: find.byType(Material),
        ),
      )
      .shape;
}

void main() {
  testWidgets('the chosen one is edged in brass', (tester) async {
    final chosen = await _shape(tester, selected: true) as OutlinedBorder;
    expect(chosen.side.color, AppColors.turn);
    final other = await _shape(tester, selected: false) as OutlinedBorder;
    expect(other.side.color, AppColors.line);
  });

  testWidgets('a tap picks it, and it fits a thumb', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      buildTestComponent(
        ChoiceTile(
          title: 'El Farolero',
          subtitle: 'Envida sin nada cuando puede',
          selected: false,
          onTap: () => taps++,
        ),
      ),
    );
    await tester.tap(find.text('El Farolero'));
    expect(taps, 1);
    expect(
      tester.getSize(find.byType(ChoiceTile)).height,
      greaterThanOrEqualTo(kMinTapTarget),
    );
  });
}
