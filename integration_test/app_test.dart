import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:score_keeper/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Game Scores App', () {
    testWidgets('Complete game flow test', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Step 1: Start a new game with 2 players
      final newGameButton = find.text('2 Players');
      await tester.tap(newGameButton);
      await tester.pumpAndSettle();

      // Verify we're on the scoring screen
      expect(find.text('Round 1'), findsOneWidget);
      
      // Step 2: Enter player names
      final playerNameFields = find.byType(TextField).evaluate().where(
        (element) => element.widget is TextField && 
                    (element.widget as TextField).decoration?.labelText == 'Player Name'
      ).toList();

      await tester.enterText(find.byWidget(playerNameFields[0].widget), 'Alice');
      await tester.enterText(find.byWidget(playerNameFields[1].widget), 'Bob');
      await tester.pumpAndSettle();

      // Step 3: Enter scores for round 1
      final scoreFields = find.byType(TextField).evaluate().where(
        (element) => element.widget is TextField && 
                    (element.widget as TextField).decoration?.labelText == 'Score'
      ).toList();

      await tester.enterText(find.byWidget(scoreFields[0].widget), '10');
      await tester.enterText(find.byWidget(scoreFields[1].widget), '5');
      await tester.pumpAndSettle();

      // Submit scores
      await tester.tap(find.text('Submit Round Scores'));
      await tester.pumpAndSettle();

      // Verify round incremented to 2
      expect(find.text('Round 2'), findsOneWidget);

      // Step 4: Navigate to History tab
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();

      // Verify history shows round 1 scores
      expect(find.text('10'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);

      // Step 5: Navigate to Graph tab
      await tester.tap(find.text('Graph'));
      await tester.pumpAndSettle();

      // Verify graph screen is shown
      expect(find.text('Score Progression'), findsOneWidget);
      
      // Step 6: Navigate back to Home (scoring) tab
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      
      // Verify we're back on round 2
      expect(find.text('Round 2'), findsOneWidget);
    });
  });
} 