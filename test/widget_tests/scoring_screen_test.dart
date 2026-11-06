import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:score_keeper/main.dart';

Widget _buildScoringScreen({
  int playerCount = 2,
  List<String> playerNames = const ['Player 1', 'Player 2'],
  List<int> currentScores = const [0, 0],
  int currentRound = 1,
  bool defaultNegative = false,
}) {
  return MaterialApp(
    home: Scaffold(
      body: ScoringScreen(
        playerCount: playerCount,
        playerNames: playerNames,
        currentScores: currentScores,
        currentRound: currentRound,
        defaultNegative: defaultNegative,
        onPlayerNameChanged: (_, __) {},
        onScoresSubmitted: (_) {},
        onDefaultSignChanged: (_) {},
      ),
    ),
  );
}

void main() {
  testWidgets('ScoringScreen shows correct round number', (WidgetTester tester) async {
    await tester.pumpWidget(_buildScoringScreen(currentRound: 3));
    expect(find.text('Round 3'), findsWidgets);
  });

  testWidgets('Default sign toggle shows correct icon', (WidgetTester tester) async {
    // Use portrait dimensions
    tester.view.physicalSize = const Size(600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(_buildScoringScreen());

    // Initially should show the "Default +" chip with add icon
    expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
    expect(find.text('Default +'), findsOneWidget);

    // Tap the default sign toggle chip
    await tester.tap(find.text('Default +'));
    await tester.pump();

    // After toggle, should show "Default -" with remove icon
    expect(find.byIcon(Icons.remove_circle_outline), findsOneWidget);
    expect(find.text('Default -'), findsOneWidget);
  });

  testWidgets('Leader card displays correct leader score', (WidgetTester tester) async {
    await tester.pumpWidget(_buildScoringScreen(
      currentScores: const [10, 20],
    ));

    // Leader card should show the highest score (20) — also appears in the player row
    expect(find.text('20'), findsWidgets);
    // Leader name should be Player 2
    expect(find.text('Player 2'), findsWidgets);
    // LEADER label
    expect(find.text('LEADER'), findsOneWidget);
  });
}
