// ignore_for_file: avoid_print
import 'dart:math';
import 'package:flutter/foundation.dart'; // Import for debugPrint
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:score_keeper/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Trix Test', () {
    testWidgets('Complete random game simulation with fixed parameters', 
      (WidgetTester tester) async {
      // Configure random generator with fixed seed for reproducibility
      final random = Random(42);
      
      debugPrint('🎮 Starting Trix Test - Game Scores App Simulation');
      
      // 1. Start a fresh instance of the app
      app.main();
      await tester.pumpAndSettle();
      debugPrint('🎮 App launched');
      
      // 2. Select 4 players
      final playerButton = find.text('4 Players');
      expect(playerButton, findsOneWidget, reason: 'Could not find 4 Players button');
      await tester.tap(playerButton);
      await tester.pumpAndSettle();
      debugPrint('🎮 Selected 4 players');
      
      // 3. Give players names - ensuring each field is visible before entering text
      final playerNames = ['Alice', 'Bob', 'Charlie', 'Dana'];
      
      // Instead of finding all fields at once, find and interact with them one by one
      // This ensures we can scroll to each field as needed
      for (int i = 0; i < 4; i++) {
        debugPrint('🎮 Entering name for player ${i+1}: ${playerNames[i]}');
        
        // Find all name fields first to get a count
        final allNameFields = find.byType(TextField).evaluate()
          .where((element) => (element.widget as TextField).decoration?.labelText == 'Player Name')
          .toList();
        
        debugPrint('🎮 Found ${allNameFields.length} name fields');
        
        // Make sure we have the expected number of fields
        if (allNameFields.length != 4) {
          debugPrint('⚠️ Warning: Expected 4 name fields, found ${allNameFields.length}');
        }
        
        // Find the specific player name field by index
        final nameFieldWidget = allNameFields[i].widget;
        
        // Ensure the field is visible by scrolling to it
        await tester.ensureVisible(find.byWidget(nameFieldWidget));
        await tester.pumpAndSettle();
        
        // Tap to focus the field
        await tester.tap(find.byWidget(nameFieldWidget));
        await tester.pumpAndSettle();
        
        // Enter the name
        await tester.enterText(find.byWidget(nameFieldWidget), playerNames[i]);
        await tester.pumpAndSettle();
        
        // Dismiss keyboard after each entry
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle(const Duration(milliseconds: 300));
      }
      
      debugPrint('🎮 Entered all player names: ${playerNames.join(", ")}');
      
      // 4. Change default scoring to negative
      // First ensure the toggle is visible
      final defaultToggle = find.text('Default');
      await tester.ensureVisible(defaultToggle);
      await tester.pumpAndSettle();
      
      expect(defaultToggle, findsOneWidget, reason: 'Could not find default sign toggle');
      await tester.tap(defaultToggle);
      await tester.pumpAndSettle();
      debugPrint('🎮 Switched default scoring to negative');
      
      // Function to enter scores for a round to avoid code duplication
      Future<void> enterRoundScores(int round, List<int> scores) async {
        debugPrint('🎮 Entering scores for Round $round');
        debugPrint('🎮 Generated scores: ${scores.join(", ")}');
        
        // Get a list of all player cards/rows - these are more stable containers
        final playerCards = find.byType(Card).evaluate().toList();
        debugPrint('🎮 Found ${playerCards.length} player cards');
        
        // Process each player card (0-indexed)
        for (int i = 0; i < 4; i++) {
          debugPrint('🎮 Processing player ${i+1} (${playerNames[i]}) with score ${scores[i]}');
          
          // Find the score field within this player's card
          final playerCard = playerCards[i];
          final scoreFields = find.descendant(
            of: find.byWidget(playerCard.widget),
            matching: find.byType(TextField)
          ).evaluate().where((element) {
            final textField = element.widget as TextField;
            return textField.decoration?.labelText == 'Score';
          }).toList();
          
          if (scoreFields.isEmpty) {
            debugPrint('⚠️ Warning: Could not find score field for player ${i+1}');
            continue;
          }
          
          final scoreFieldWidget = scoreFields.first.widget;
          
          // Ensure the field is visible
          await tester.ensureVisible(find.byWidget(scoreFieldWidget));
          await tester.pumpAndSettle();
          
          // Check if we need to toggle the sign
          final bool shouldBePositive = scores[i] > 0;
          
          if (shouldBePositive) {
            // Find the sign toggle within this player's card
            final signToggle = find.descendant(
              of: find.byWidget(playerCard.widget),
              matching: find.byIcon(Icons.remove_circle)
            );
            
            if (signToggle.evaluate().isNotEmpty) {
              // Ensure toggle is visible and tap it
              await tester.ensureVisible(signToggle.first);
              await tester.pumpAndSettle();
              await tester.tap(signToggle.first);
              await tester.pumpAndSettle();
              debugPrint('🎮 Toggled sign for player ${i+1} to positive');
            } else {
              debugPrint('⚠️ Warning: Could not find sign toggle for player ${i+1}');
            }
          }
          
          // Focus the field
          await tester.tap(find.byWidget(scoreFieldWidget));
          await tester.pumpAndSettle();
          
          // Clear any existing text first
          await tester.enterText(find.byWidget(scoreFieldWidget), '');
          await tester.pumpAndSettle();
          
          // Enter the absolute value of the score
          await tester.enterText(
            find.byWidget(scoreFieldWidget), 
            scores[i].abs().toString()
          );
          await tester.pumpAndSettle();
          debugPrint('🎮 Entered score ${scores[i].abs()} for player ${i+1}');
          
          // Dismiss keyboard after each entry
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pumpAndSettle();
        }
        
        // Submit the scores - ensure button is visible first
        final submitButton = find.text('Submit Round Scores');
        await tester.ensureVisible(submitButton);
        await tester.pumpAndSettle();
        
        await tester.tap(submitButton);
        await tester.pumpAndSettle();
        debugPrint('🎮 Submitted scores for Round $round');
      }
      
      // 5. Enter 4 rounds of random scores with constraints
      for (int round = 1; round <= 4; round++) {
        // Generate scores that sum to -500, as multiples of 5, with 8% chance of being positive
        List<int> scores = _generateConstrainedScores(random, 4, -500, 5, 0.08);
        await enterRoundScores(round, scores);
      }
      
      // 6. Navigate to History tab and stay for 4 seconds
      final historyTab = find.text('History');
      await tester.ensureVisible(historyTab);
      await tester.pumpAndSettle();
      
      await tester.tap(historyTab);
      await tester.pumpAndSettle();
      debugPrint('🎮 Navigated to History tab');
      
      // Stay on History tab for 4 seconds
      await tester.pump(const Duration(seconds: 4));
      debugPrint('🎮 Stayed on History tab for 4 seconds');
      
      // 7. Navigate to Graph tab and stay for 4 seconds
      final graphTab = find.text('Graph');
      await tester.ensureVisible(graphTab);
      await tester.pumpAndSettle();
      
      await tester.tap(graphTab);
      await tester.pumpAndSettle();
      debugPrint('🎮 Navigated to Graph tab');
      
      // Stay on Graph tab for 4 seconds
      await tester.pump(const Duration(seconds: 4));
      debugPrint('🎮 Stayed on Graph tab for 4 seconds');
      
      // 8. Go back to Home tab
      final homeTab = find.text('Home');
      await tester.ensureVisible(homeTab);
      await tester.pumpAndSettle();
      
      await tester.tap(homeTab);
      await tester.pumpAndSettle();
      debugPrint('🎮 Returned to Home tab');
      
      // 9. Enter 4 more rounds with the same constraints
      for (int round = 5; round <= 8; round++) {
        // Generate scores that sum to -500, as multiples of 5, with 8% chance of being positive
        List<int> scores = _generateConstrainedScores(random, 4, -500, 5, 0.08);
        await enterRoundScores(round, scores);
      }
      
      // 10. Keep the app open for manual review (don't tear down)
      debugPrint('🎮 Test complete - App left open for manual review');
      debugPrint('🎮 Final state after 8 rounds of play with 4 players');
      
      // The tester will automatically dispose after a timeout, but we want to keep it open
      // We can use a very long delay to give the user time to review
      await tester.pump(const Duration(minutes: 30)); // 30 minutes should be enough
    });
  });
}

/// Generates a list of random scores that sum to the target value
/// All scores will be multiples of the specified base
/// A percentage of scores will have the opposite sign from the majority
List<int> _generateConstrainedScores(
  Random random, 
  int count, 
  int targetSum, 
  int multipleOf, 
  double oppositeProbability
) {
  // Determine if we're generating mostly negative or positive scores
  final bool mostlyNegative = targetSum < 0;
  
  // Generate initial scores as multiples of the base
  List<int> scores = List.generate(count, (_) {
    // Generate a multiple of the base
    int baseScore = (random.nextInt(20) + 1) * multipleOf * 5; // Between 5 and 500, multiple of 5
    
    // Determine if this score should have the opposite sign
    bool shouldBeOpposite = random.nextDouble() < oppositeProbability;
    
    if (mostlyNegative) {
      return shouldBeOpposite ? baseScore : -baseScore;
    } else {
      return shouldBeOpposite ? -baseScore : baseScore;
    }
  });
  
  // Calculate the current sum
  int currentSum = scores.fold(0, (sum, score) => sum + score);
  
  // Adjust the last score to make the total equal to targetSum
  int difference = targetSum - currentSum;
  
  // Round the difference to the nearest multiple
  int roundedDifference = (difference ~/ multipleOf) * multipleOf;
  if (difference % multipleOf > multipleOf ~/ 2) {
    roundedDifference += multipleOf;
  }
  
  // Apply the adjustment to the last score
  scores[count - 1] += roundedDifference;
  
  // Verify that the scores sum to the target value
  assert(scores.fold(0, (sum, score) => sum + score) == targetSum,
         'Scores do not sum to target value');
  
  // Verify that all scores are multiples of the base
  for (int score in scores) {
    assert(score.abs() % multipleOf == 0, 'Score $score is not a multiple of $multipleOf');
  }
  
  return scores;
} 