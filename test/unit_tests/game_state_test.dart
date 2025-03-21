import 'package:flutter_test/flutter_test.dart';
import 'package:score_keeper/models/game_state.dart';

void main() {
  group('GameState Tests', () {
    test('newGame initializes with correct values', () {
      final gameState = GameState.newGame(3);
      
      expect(gameState.isGameStarted, true);
      expect(gameState.playerCount, 3);
      expect(gameState.currentRound, 1);
      expect(gameState.scoreHistory, isEmpty);
      expect(gameState.currentScores, [0, 0, 0, 0]);
      expect(gameState.defaultNegative, false);
    });
    
    test('submitRoundScores updates scores correctly', () {
      final gameState = GameState.newGame(2);
      gameState.submitRoundScores([10, -5]);
      
      expect(gameState.currentScores[0], 10);
      expect(gameState.currentScores[1], -5);
      expect(gameState.currentRound, 2);
      expect(gameState.scoreHistory.length, 1);
    });
    
    test('revertToRound removes later rounds', () {
      final gameState = GameState.newGame(2);
      gameState.submitRoundScores([10, 20]);
      gameState.submitRoundScores([5, 15]);
      gameState.revertToRound(1);
      
      expect(gameState.scoreHistory.length, 1);
      expect(gameState.currentRound, 2);
      expect(gameState.currentScores[0], 10);
      expect(gameState.currentScores[1], 20);
    });
    
    test('setDefaultNegative persists the preference', () {
      final gameState = GameState.newGame(2);
      expect(gameState.defaultNegative, false);
      
      gameState.setDefaultNegative(true);
      expect(gameState.defaultNegative, true);
      
      gameState.setDefaultNegative(false);
      expect(gameState.defaultNegative, false);
    });
    
    test('updatePlayerName changes player name', () {
      final gameState = GameState.newGame(2);
      gameState.updatePlayerName(0, "Alice");
      gameState.updatePlayerName(1, "Bob");
      
      expect(gameState.playerNames[0], "Alice");
      expect(gameState.playerNames[1], "Bob");
    });
  });
} 