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
    expect(find.text('Round 3'), findsOneWidget);
  });

  testWidgets('Default sign toggle shows correct icon', (WidgetTester tester) async {
    // Use portrait dimensions so the compact 'Default' toggle renders
    tester.view.physicalSize = const Size(600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(_buildScoringScreen());

    // Initially should show add icon (positive)
    expect(find.byIcon(Icons.add_circle), findsOneWidget);
    expect(find.byIcon(Icons.remove_circle), findsNothing);

    // Find and tap the default sign toggle
    await tester.tap(find.text('Default'));
    await tester.pump();

    // After toggle, should show remove icon (negative)
    expect(find.byIcon(Icons.remove_circle), findsOneWidget);
    expect(find.byIcon(Icons.add_circle), findsNothing);
  });

  testWidgets('Score boxes display correct values', (WidgetTester tester) async {
    await tester.pumpWidget(_buildScoringScreen(
      currentScores: const [10, 20],
    ));

    // Total score should be 30 (10 + 20)
    expect(find.text('30'), findsOneWidget);

    // Initial round score should be 0
    expect(find.text('0'), findsWidgets);
  });
}
