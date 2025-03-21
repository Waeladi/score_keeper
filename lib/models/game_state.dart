import 'dart:convert';
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
    final prefs = await SharedPreferences.getInstance();
    
    final isGameStarted = prefs.getBool('isGameStarted') ?? false;
    if (!isGameStarted) {
      return GameState();
    }
    
    final playerCount = prefs.getInt('playerCount') ?? 2;
    
    List<String> playerNames = List.generate(4, (index) => "Player ${index + 1}");
    final playerNamesJson = prefs.getStringList('playerNames');
    if (playerNamesJson != null) {
      playerNames = playerNamesJson;
    }
    
    List<int> currentScores = List.filled(4, 0);
    final currentScoresJson = prefs.getString('currentScores');
    if (currentScoresJson != null) {
      currentScores = List<int>.from(jsonDecode(currentScoresJson));
    }
    
    List<List<int>> scoreHistory = [];
    final scoreHistoryJson = prefs.getString('scoreHistory');
    if (scoreHistoryJson != null) {
      final List<dynamic> decodedHistory = jsonDecode(scoreHistoryJson);
      scoreHistory = decodedHistory.map((round) => List<int>.from(round)).toList();
    }
    
    final currentRound = prefs.getInt('currentRound') ?? 1;
    final defaultNegative = prefs.getBool('defaultNegative') ?? false;
    
    return GameState(
      isGameStarted: isGameStarted,
      playerCount: playerCount,
      playerNames: playerNames,
      currentScores: currentScores,
      scoreHistory: scoreHistory,
      currentRound: currentRound,
      defaultNegative: defaultNegative,
    );
  }

  // Save game state to SharedPreferences
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isGameStarted', isGameStarted);
    await prefs.setInt('playerCount', playerCount);
    await prefs.setStringList('playerNames', playerNames);
    await prefs.setString('currentScores', jsonEncode(currentScores));
    await prefs.setString('scoreHistory', jsonEncode(scoreHistory));
    await prefs.setInt('currentRound', currentRound);
    await prefs.setBool('defaultNegative', defaultNegative);
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
} 