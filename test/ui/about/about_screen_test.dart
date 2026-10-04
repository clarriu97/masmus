import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/services/links.dart';
import 'package:masmus/ui/about/about_screen.dart';

import '../../helpers/test_app.dart';

void main() {
  testWidgets('the version, and the web, privacy, terms and contact open '
      'outside the app', (tester) async {
    final links = RecordedLinks();
    await tester.pumpWidget(buildTestApp(AboutScreen(links: links)));
    expect(find.text('Versión $appVersion ($appBuild)'), findsOneWidget);
    expect(find.textContaining('no salen del móvil'), findsOneWidget);

    for (final title in ['Web', 'Privacidad', 'Condiciones de uso']) {
      await tester.tap(find.text(title));
    }
    await tester.ensureVisible(find.text('Contacto'));
    await tester.tap(find.text('Contacto'));
    expect(links.opened, [
      Uri.parse('https://masmus.larri.dev/'),
      Uri.parse('https://masmus.larri.dev/privacy/'),
      Uri.parse('https://masmus.larri.dev/terms/'),
      Uri.parse('mailto:info.masmus@larri.dev'),
    ]);
  });

  testWidgets('a link nothing can open says so', (tester) async {
    await tester.pumpWidget(
      buildTestApp(AboutScreen(links: RecordedLinks(opens: false))),
    );
    await tester.tap(find.text('Privacidad'));
    await tester.pump();
    expect(find.text('No se ha podido abrir Privacidad'), findsOneWidget);
  });

  testWidgets('the licenses of everything the app is made with', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp(AboutScreen(links: RecordedLinks())));
    await tester.ensureVisible(find.text('Licencias'));
    await tester.tap(find.text('Licencias'));
    await tester.pumpAndSettle();
    expect(find.byType(LicensePage), findsOneWidget);
  });
}
