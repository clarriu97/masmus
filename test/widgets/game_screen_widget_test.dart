import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/bots/heuristic_bot.dart';
import 'package:masmus/controllers/match_controller.dart';
import 'package:masmus/core/theme/app_text_styles.dart';
import 'package:masmus/game/cards.dart';
import 'package:masmus/game/rules.dart';
import 'package:masmus/screens/game_screen.dart';
import 'package:masmus/services/match_store.dart';
import 'package:masmus/services/scheduler.dart';
import 'package:masmus/widgets/mus_table.dart';
import 'package:masmus/widgets/playing_card_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  AppTextStyles.useGoogleFonts = false;

  const MethodChannel vibrationChannel = MethodChannel('vibration');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(vibrationChannel, (
          MethodCall methodCall,
        ) async {
          if (methodCall.method == 'hasVibrator') {
            return true;
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(vibrationChannel, null);
  });

  Future<ManualScheduler> pumpTable(
    WidgetTester tester, {
    int mano = 0,
    int seed = 4,
  }) async {
    final scheduler = ManualScheduler();
    await tester.pumpWidget(
      MaterialApp(
        home: GameScreen(
          partner: Personality.calculador,
          seed: seed,
          mano: mano,
          scheduler: scheduler,
          store: MatchStore.inMemory(),
        ),
      ),
    );
    return scheduler;
  }

  testWidgets('as mano, you are asked mus or no hay mus', (tester) async {
    await pumpTable(tester);
    expect(find.byType(MusTable), findsOneWidget);
    expect(find.text('MUS'), findsOneWidget);
    expect(find.text('NO HAY MUS'), findsOneWidget);
    expect(find.text('Nosotros: 0'), findsOneWidget);
  });

  testWidgets('cutting the mus starts the grande, with you to speak', (
    tester,
  ) async {
    await pumpTable(tester);
    await tester.tap(find.text('NO HAY MUS'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Grande'), findsOneWidget);
    expect(find.text('PASO'), findsOneWidget);
    expect(find.text('ÓRDAGO'), findsOneWidget);
  });

  testWidgets('the bots speak on their own, after their thinking pause', (
    tester,
  ) async {
    final scheduler = await pumpTable(tester, mano: 1);
    expect(find.text('Esperando a El Prudente...'), findsOneWidget);
    expect(find.textContaining('MUS'), findsNothing);
    scheduler.advance(Pace.normal.thinking);
    await tester.pump();
    expect(find.textContaining('MUS'), findsWidgets);
  });

  testWidgets('in the discard you mark the cards to change, then discard '
      'them', (tester) async {
    final scheduler = await pumpTable(tester, seed: 2);
    await tester.tap(find.text('MUS'));
    await tester.pump();
    for (var bot = 0; bot < 3; bot++) {
      scheduler.advance(Pace.normal.thinking);
      await tester.pump();
    }
    final none = find.widgetWithText(ElevatedButton, 'DESCARTAR (0)');
    expect(tester.widget<ElevatedButton>(none).onPressed, isNull);

    await tester.tap(find.byType(PlayingCardWidget).first);
    await tester.pump();
    expect(
      tester
          .widget<PlayingCardWidget>(find.byType(PlayingCardWidget).first)
          .isSelected,
      isTrue,
    );
    final one = find.widgetWithText(ElevatedButton, 'DESCARTAR (1)');
    expect(tester.widget<ElevatedButton>(one).onPressed, isNotNull);

    await tester.tap(one);
    await tester.pump();
    expect(find.textContaining('DESCARTAR'), findsNothing);
    expect(find.text('Esperando a El Prudente...'), findsOneWidget);
  });

  testWidgets('a whole match can be played at the table, to the end', (
    tester,
  ) async {
    final scheduler = ManualScheduler();
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => GameScreen(
                  partner: Personality.calculador,
                  rules: const Rules(target: 30),
                  seed: 9,
                  scheduler: scheduler,
                  store: MatchStore.inMemory(),
                ),
              ),
            ),
            child: const Text('Jugar'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Jugar'));
    await tester.pumpAndSettle();

    for (var step = 0; step < 3000; step++) {
      if (find.text('Volver').evaluate().isNotEmpty) {
        break;
      }
      final button = [
        find.text('Siguiente mano'),
        for (final label in ['NO HAY MUS', 'PASO', 'QUIERO'])
          find.widgetWithText(ElevatedButton, label),
      ].where((finder) => finder.evaluate().isNotEmpty).firstOrNull;
      if (button == null) {
        scheduler.advance(Pace.normal.thinking);
      } else {
        await tester.tap(button.first);
      }
      await tester.pump();
    }
    expect(find.text('Volver'), findsOneWidget);
    expect(
      find.textContaining(RegExp('¡Ganáis la partida!|Ganan ellos')),
      findsOneWidget,
    );

    await tester.tap(find.text('Volver'));
    await tester.pumpAndSettle();
    expect(find.text('Jugar'), findsOneWidget);
  });

  testWidgets('MusTable shows your cards face up', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MusTable(
            seats: [
              TableSeat(
                name: 'Tú',
                cards: [PlayingCard.parse('1o'), PlayingCard.parse('Rc')],
              ),
              const TableSeat(name: 'Bot', cards: []),
            ],
            onCardTap: (seat, card) {},
          ),
        ),
      ),
    );
    expect(find.byType(PlayingCardWidget), findsNWidgets(2));
    expect(find.text('1'), findsNWidgets(2));
    expect(find.text('12'), findsNWidgets(2));
  });
}
