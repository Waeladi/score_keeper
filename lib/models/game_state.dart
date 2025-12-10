import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameState {
  bool isGameStarted;
  int playerCount;
  List<String> playerNames;
  List<int> currentScores;
  List<List<int>> scoreHistory;
  int currentRound;
  bool defaultNegative;

  GameState({
    this.isGameStarted = false,
    this.playerCount = 2,
    List<String>? playerNames,
    List<int>? currentScores,
    List<List<int>>? scoreHistory,
    this.currentRound = 1,
    this.defaultNegative = false,
  }) : 
    playerNames = playerNames ?? List.generate(4, (index) => "Player ${index + 1}"),
    currentScores = currentScores ?? List.filled(4, 0),
    scoreHistory = scoreHistory ?? [];

  // Create a new game with the specified player count
  factory GameState.newGame(int playerCount) {
    return GameState(
      isGameStarted: true,
      playerCount: playerCount,
      playerNames: List.generate(4, (index) => "Player ${index + 1}"),
      currentScores: List.filled(4, 0),
      scoreHistory: [],
      currentRound: 1,
      defaultNegative: false,
    );
  }

  // Load game state from SharedPreferences
  static Future<GameState> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final gameStateJson = prefs.getString('gameState');
      
      if (gameStateJson == null || gameStateJson.isEmpty) {
        return GameState(isGameStarted: false);
      }
      
      try {
        final Map<String, dynamic> gameStateMap = jsonDecode(gameStateJson);
        // Add validation for critical fields
        if (gameStateMap['playerCount'] == null || 
            gameStateMap['playerCount']! < 2 || 
            gameStateMap['playerCount']! > 4) {
          throw FormatException('Invalid player count');
        }
        
        return GameState(
          isGameStarted: gameStateMap['isGameStarted'] ?? false,
          playerCount: gameStateMap['playerCount'] ?? 2,
          playerNames: List<String>.from(gameStateMap['playerNames'] ?? []),
          currentScores: List<int>.from(gameStateMap['currentScores'] ?? []),
          scoreHistory: List<List<int>>.from(
            (gameStateMap['scoreHistory'] ?? []).map((e) => List<int>.from(e))
          ),
          currentRound: gameStateMap['currentRound'] ?? 1,
          defaultNegative: gameStateMap['defaultNegative'] ?? false,
        );
      } catch (e) {
        debugPrint('Error parsing saved game state: $e');
        // Clear corrupted data
        await prefs.remove('gameState');
        return GameState(isGameStarted: false);
      }
    } catch (e) {
      debugPrint('Error loading game state: $e');
      return GameState(isGameStarted: false);
    }
  }

  // Make fromJson more robust with null checks and defaults
  factory GameState.fromJson(Map<String, dynamic> json) {
    try {
      List<String> playerNames = [];
      List<int> currentScores = [];
      List<List<int>> scoreHistory = [];
      
      // Handle player names with null checks
      if (json['playerNames'] != null) {
        playerNames = List<String>.from(json['playerNames']);
      } else {
        playerNames = List.filled(json['playerCount'] ?? 0, '');
      }
      
      // Handle current scores with null checks
      if (json['currentScores'] != null) {
        currentScores = List<int>.from(json['currentScores']);
      } else {
        currentScores = List.filled(json['playerCount'] ?? 0, 0);
      }
      
      // Handle score history with null checks
      if (json['scoreHistory'] != null) {
        scoreHistory = List<List<int>>.from(
          json['scoreHistory'].map((round) => List<int>.from(round))
        );
      }
      
      return GameState(
        playerCount: json['playerCount'] ?? 0,
        playerNames: playerNames,
        currentScores: currentScores,
        scoreHistory: scoreHistory,
        defaultNegative: json['defaultNegative'] ?? false,
      );
    } catch (e) {
      debugPrint('Error in fromJson: $e');
      // Return a safe default state
      return GameState.newGame(0);
    }
  }

  // Save game state to SharedPreferences
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gameState', jsonEncode(toJson()));
  }

  // Update a player's name
  void updatePlayerName(int index, String name) {
    playerNames[index] = name;
  }

  // Submit scores for a round
  void submitRoundScores(List<int> roundScores) {
    scoreHistory.add(roundScores);
    
    for (int i = 0; i < playerCount; i++) {
      currentScores[i] += roundScores[i];
    }
    
    currentRound++;
  }

  // Add this new method
  void revertToRound(int roundNumber) {
    // Truncate score history to the selected round
    scoreHistory = scoreHistory.sublist(0, roundNumber);
    
    // Recalculate player totals
    for (int i = 0; i < playerCount; i++) {
      currentScores[i] = scoreHistory.fold(0, (sum, round) => sum + round[i]);
    }
    
    // Update current round
    currentRound = roundNumber + 1;
  }

  // Add this new method
  void setDefaultNegative(bool value) {
    defaultNegative = value;
  }

  Map<String, dynamic> toJson() => {
    'isGameStarted': isGameStarted,
    'playerCount': playerCount,
    'playerNames': playerNames,
    'currentScores': currentScores,
    'scoreHistory': scoreHistory,
    'currentRound': currentRound,
    'defaultNegative': defaultNegative,
  };
} 