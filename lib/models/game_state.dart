import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

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
    playerNames = playerNames ?? List.generate(AppConstants.maxPlayers, (index) => "Player ${index + 1}"),
    currentScores = currentScores ?? List.filled(AppConstants.maxPlayers, 0),
    scoreHistory = scoreHistory ?? [];

  factory GameState.newGame(int playerCount) {
    return GameState(
      isGameStarted: true,
      playerCount: playerCount,
      playerNames: List.generate(AppConstants.maxPlayers, (index) => "Player ${index + 1}"),
      currentScores: List.filled(AppConstants.maxPlayers, 0),
      scoreHistory: [],
      currentRound: 1,
      defaultNegative: false,
    );
  }

  factory GameState.fromJson(Map<String, dynamic> json) {
    try {
      final playerCount = json['playerCount'] ?? 2;
      if (playerCount < 2 || playerCount > AppConstants.maxPlayers) {
        throw const FormatException('Invalid player count');
      }

      return GameState(
        isGameStarted: json['isGameStarted'] ?? false,
        playerCount: playerCount,
        playerNames: json['playerNames'] != null
            ? List<String>.from(json['playerNames'])
            : List.generate(AppConstants.maxPlayers, (index) => "Player ${index + 1}"),
        currentScores: json['currentScores'] != null
            ? List<int>.from(json['currentScores'])
            : List.filled(AppConstants.maxPlayers, 0),
        scoreHistory: json['scoreHistory'] != null
            ? List<List<int>>.from(
                json['scoreHistory'].map((round) => List<int>.from(round)))
            : [],
        currentRound: json['currentRound'] ?? 1,
        defaultNegative: json['defaultNegative'] ?? false,
      );
    } catch (e) {
      debugPrint('Error in fromJson: $e');
      return GameState(isGameStarted: false);
    }
  }

  static Future<GameState> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final gameStateJson = prefs.getString('gameState');

      if (gameStateJson == null || gameStateJson.isEmpty) {
        return GameState(isGameStarted: false);
      }

      try {
        final Map<String, dynamic> json = jsonDecode(gameStateJson);
        return GameState.fromJson(json);
      } catch (e) {
        debugPrint('Error parsing saved game state: $e');
        await prefs.remove('gameState');
        return GameState(isGameStarted: false);
      }
    } catch (e) {
      debugPrint('Error loading game state: $e');
      return GameState(isGameStarted: false);
    }
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gameState', jsonEncode(toJson()));
  }

  void updatePlayerName(int index, String name) {
    playerNames[index] = name;
  }

  void submitRoundScores(List<int> roundScores) {
    scoreHistory.add(roundScores);

    for (int i = 0; i < playerCount; i++) {
      currentScores[i] += roundScores[i];
    }

    currentRound++;
  }

  void revertToRound(int roundNumber) {
    scoreHistory = scoreHistory.sublist(0, roundNumber);

    for (int i = 0; i < playerCount; i++) {
      currentScores[i] = scoreHistory.fold(0, (sum, round) => sum + round[i]);
    }

    currentRound = roundNumber + 1;
  }

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
