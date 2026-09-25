import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/core/game/models/card.dart';
import 'package:masmus/core/game/models/player.dart';
import 'package:masmus/core/theme/app_text_styles.dart';
import 'package:masmus/screens/game_screen.dart';
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

  testWidgets('GameScreen renders main components', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: GameScreen(initialMano: 0)),
    );
    await tester.pump(const Duration(seconds: 1)); // Wait for initial delay
    await tester.pumpAndSettle();

    expect(find.byType(MusTable), findsOneWidget);
    expect(find.text('MUS'), findsOneWidget);
    expect(find.text('NO HAY MUS'), findsOneWidget);
  });

  testWidgets('MusTable renders cards correctly', (WidgetTester tester) async {
    final player = Player(id: 'p0', name: 'Test');
    player.receiveCards([
      const MusCard(suit: Suit.oros, faceValue: 1),
      const MusCard(suit: Suit.copas, faceValue: 12),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MusTable(
            players: [
              player,
              Player(id: 'p1', name: 'Bot1'),
            ],
            onCardTap: (i, c) {},
          ),
        ),
      ),
    );

    expect(find.byType(PlayingCardWidget), findsWidgets);
    expect(find.text('1'), findsNWidgets(2));
    expect(find.text('12'), findsNWidgets(2));
  });

  testWidgets('Tapping card toggles selection visualization', (
    WidgetTester tester,
  ) async {
    // We test Logic via UI state update in GameScreen
    await tester.pumpWidget(
      const MaterialApp(home: GameScreen(initialMano: 0)),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    final cardFinder = find.byType(PlayingCardWidget).first;
    await tester.tap(cardFinder);
    await tester.pump();
  });
}
