import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:score_keeper/main.dart';

void main() {
  testWidgets('ScoringScreen shows correct round number', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ScoringScreen(
          playerCount: 2,
          playerNames: const ['Player 1', 'Player 2'],
          currentScores: const [0, 0],
          currentRound: 3,
          defaultNegative: false,
          onPlayerNameChanged: (_, __) {},
          onScoresSubmitted: (_) {},
          onDefaultSignChanged: (_) {},
        ),
      ),
    );
    
    expect(find.text('Round 3'), findsOneWidget);
  });
  
  testWidgets('Default sign toggle shows correct icon', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ScoringScreen(
          playerCount: 2,
          playerNames: const ['Player 1', 'Player 2'],
          currentScores: const [0, 0],
          currentRound: 1,
          defaultNegative: false,
          onPlayerNameChanged: (_, __) {},
          onScoresSubmitted: (_) {},
          onDefaultSignChanged: (_) {},
        ),
      ),
    );
    
    // Initially should show add icon (positive)
    expect(find.byIcon(Icons.add_circle), findsOneWidget);
    expect(find.byIcon(Icons.remove_circle), findsNothing);
    
    // Find and tap the default sign toggle
    final Finder defaultToggle = find.text('Default');
    await tester.tap(defaultToggle);
    await tester.pump();
    
    // After toggle, should show remove icon (negative)
    expect(find.byIcon(Icons.remove_circle), findsOneWidget);
    expect(find.byIcon(Icons.add_circle), findsNothing);
  });
  
  testWidgets('Score boxes display correct values', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ScoringScreen(
          playerCount: 2,
          playerNames: const ['Player 1', 'Player 2'],
          currentScores: const [10, 20],
          currentRound: 1,
          defaultNegative: false,
          onPlayerNameChanged: (_, __) {},
          onScoresSubmitted: (_) {},
          onDefaultSignChanged: (_) {},
        ),
      ),
    );
    
    // Total score should be 30 (10 + 20)
    expect(find.text('30'), findsOneWidget);
    
    // Initial round score should be 0
    expect(find.text('0'), findsWidgets);
  });
} 