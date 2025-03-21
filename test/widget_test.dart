// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:score_keeper/main.dart';
import 'package:score_keeper/models/game_state.dart';

void main() {
  testWidgets('App should start with New Game screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ScoreKeeperApp());

    // Verify that the New Game screen is shown
    expect(find.text('Select Number of Players'), findsOneWidget);
    expect(find.text('2 Players'), findsOneWidget);
    expect(find.text('3 Players'), findsOneWidget);
    expect(find.text('4 Players'), findsOneWidget);
  });

  test('GameState should initialize correctly', () {
    final gameState = GameState();
    
    expect(gameState.isGameStarted, false);
    expect(gameState.playerCount, 2);
    expect(gameState.playerNames.length, 4);
    expect(gameState.currentScores.length, 4);
    expect(gameState.scoreHistory.length, 0);
    expect(gameState.currentRound, 1);
  });

  test('GameState.newGame should create a new game with specified player count', () {
    final gameState = GameState.newGame(3);
    
    expect(gameState.isGameStarted, true);
    expect(gameState.playerCount, 3);
    expect(gameState.playerNames.length, 4);
    expect(gameState.currentScores.length, 4);
    expect(gameState.scoreHistory.length, 0);
    expect(gameState.currentRound, 1);
  });

  test('GameState.updatePlayerName should update player name', () {
    final gameState = GameState.newGame(2);
    
    gameState.updatePlayerName(0, 'Alice');
    gameState.updatePlayerName(1, 'Bob');
    
    expect(gameState.playerNames[0], 'Alice');
    expect(gameState.playerNames[1], 'Bob');
  });

  test('GameState.submitRoundScores should update scores and history', () {
    final gameState = GameState.newGame(2);
    
    gameState.submitRoundScores([10, 5, 0, 0]);
    
    expect(gameState.currentScores[0], 10);
    expect(gameState.currentScores[1], 5);
    expect(gameState.scoreHistory.length, 1);
    expect(gameState.scoreHistory[0][0], 10);
    expect(gameState.scoreHistory[0][1], 5);
    expect(gameState.currentRound, 2);
    
    gameState.submitRoundScores([-5, 15, 0, 0]);
    
    expect(gameState.currentScores[0], 5);
    expect(gameState.currentScores[1], 20);
    expect(gameState.scoreHistory.length, 2);
    expect(gameState.scoreHistory[1][0], -5);
    expect(gameState.scoreHistory[1][1], 15);
    expect(gameState.currentRound, 3);
  });
}
