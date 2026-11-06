import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_state.dart';
import '../utils/constants.dart';
import 'scoring_screen.dart';
import 'history_screen.dart';
import 'new_game_screen.dart';
import 'graph_screen.dart';

class MainScreen extends StatefulWidget {
  final FirebaseAnalytics? analytics;

  const MainScreen({
    super.key,
    required this.analytics,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const List<String> _tabTitles = ['Home', 'History', 'New Game', 'Graph'];
  static const int _newGameTabIndex = 2;
  static const int _homeTabIndex = 0;

  late int _selectedIndex;
  late GameState _gameState;
  bool _isLoading = true;
  String _appVersion = '';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _selectedIndex = _newGameTabIndex;
    _loadGameState();
    _loadPackageInfo();
  }

  Future<void> _loadGameState() async {
    try {
      final gameState = await GameState.load();
      if (!mounted) return;
      setState(() {
        _gameState = gameState;
        _isLoading = false;
        _selectedIndex = _gameState.isGameStarted ? _homeTabIndex : _newGameTabIndex;
      });
    } catch (e, stackTrace) {
      debugPrint('Critical error loading state: $e\n$stackTrace');
      if (!mounted) return;
      setState(() {
        _gameState = GameState(isGameStarted: false);
        _isLoading = false;
        _selectedIndex = _newGameTabIndex;
      });
      await (await SharedPreferences.getInstance()).remove('gameState');
    }
  }

  Future<void> _loadPackageInfo() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() {
        _appVersion = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
      });
    } catch (e) {
      debugPrint('Error loading package info: $e');
      if (!mounted) return;
      setState(() {
        _appVersion = '?.?.?';
        _buildNumber = '?';
      });
    }
  }

  void _startNewGame(int playerCount, bool lowScoreWins) {
    if (_gameState.isGameStarted && _gameState.scoreHistory.isNotEmpty) {
      _showNewGameConfirmationDialog(playerCount, lowScoreWins);
    } else {
      _confirmStartNewGame(playerCount, lowScoreWins);
    }
  }

  void _showNewGameConfirmationDialog(int playerCount, bool lowScoreWins) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start New Game?'),
        content: const Text(
          'Starting a new game will erase all current scores and history. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _confirmStartNewGame(playerCount, lowScoreWins);
            },
            child: const Text('Start New Game'),
          ),
        ],
      ),
    );
  }

  void _confirmStartNewGame(int playerCount, bool lowScoreWins) {
    _logNavEvent(_homeTabIndex);
    setState(() {
      _gameState = GameState.newGame(playerCount, lowScoreWins: lowScoreWins);
      _selectedIndex = _homeTabIndex;
    });
    _gameState.save();
  }

  void _updatePlayerName(int index, String name) {
    setState(() {
      _gameState.updatePlayerName(index, name);
    });
    _gameState.save();
  }

  void _submitRoundScores(List<int> roundScores) {
    setState(() {
      _gameState.submitRoundScores(roundScores);
    });
    _gameState.save();
  }

  void _updateDefaultSignPreference(bool isNegative) {
    setState(() {
      _gameState.setDefaultNegative(isNegative);
    });
    _gameState.save();
  }

  void _updateLowScoreWins(bool lowScoreWins) {
    setState(() {
      _gameState.lowScoreWins = lowScoreWins;
    });
    _gameState.save();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      _logNavEvent(index);
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _logNavEvent(int index) {
    if (widget.analytics == null) return;

    widget.analytics!.logEvent(
      name: 'nav_click',
      parameters: {
        'tab_name': _tabTitles[index],
        'previous_tab': _selectedIndex < _tabTitles.length ? _tabTitles[_selectedIndex] : 'Unknown',
      },
    );
  }

  void _resetCurrentGame() {
    setState(() {
      _gameState.currentScores = List.filled(AppConstants.maxPlayers, 0);
      _gameState.scoreHistory.clear();
      _gameState.currentRound = 1;
      _selectedIndex = _homeTabIndex;
    });
    _gameState.save();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Game Reset! Scores and history cleared.'),
      ),
    );
  }

  void _showResetConfirmationDialog() {
    if (!_gameState.isGameStarted || _gameState.scoreHistory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No game progress to reset.'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Current Game?'),
        content: const Text(
          'This will clear all scores for the current players. Player names will be kept. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppConstants.error),
            onPressed: () {
              Navigator.of(context).pop();
              _resetCurrentGame();
            },
            child: const Text('Reset Game'),
          ),
        ],
      ),
    );
  }

  void _revertToRound(int roundNumber) {
    setState(() {
      _gameState.revertToRound(roundNumber);
      _selectedIndex = _homeTabIndex;
    });
    _gameState.save();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Game reverted to Round $roundNumber. Now playing Round ${roundNumber + 1}.'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    Widget mainContent;
    if (!_gameState.isGameStarted) {
      mainContent = NewGameScreen(
        onNewGame: _startNewGame,
        currentGameState: _gameState,
        onResetGame: null,
        appVersion: _appVersion,
        buildNumber: _buildNumber,
      );
    } else {
      final List<Widget> screens = [
        ScoringScreen(
          playerCount: _gameState.playerCount,
          playerNames: _gameState.playerNames,
          currentScores: _gameState.currentScores,
          currentRound: _gameState.currentRound,
          defaultNegative: _gameState.defaultNegative,
          lowScoreWins: _gameState.lowScoreWins,
          onPlayerNameChanged: _updatePlayerName,
          onScoresSubmitted: _submitRoundScores,
          onDefaultSignChanged: _updateDefaultSignPreference,
          onLowScoreWinsChanged: _updateLowScoreWins,
        ),
        HistoryScreen(
          playerCount: _gameState.playerCount,
          playerNames: _gameState.playerNames,
          scoreHistory: _gameState.scoreHistory,
          onRevertToRound: _revertToRound,
        ),
        NewGameScreen(
          onNewGame: _startNewGame,
          onResetGame: _showResetConfirmationDialog,
          currentGameState: _gameState,
          appVersion: _appVersion,
          buildNumber: _buildNumber,
        ),
        GraphScreen(
          playerCount: _gameState.playerCount,
          playerNames: _gameState.playerNames,
          scoreHistory: _gameState.scoreHistory,
          currentScores: _gameState.currentScores,
        ),
      ];
      // IndexedStack keeps each tab alive so unsubmitted score entries
      // survive switching tabs.
      mainContent = IndexedStack(index: _selectedIndex, children: screens);
    }

    String appBarTitle = _gameState.isGameStarted
        ? AppConstants.appName
        : AppConstants.appName;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(appBarTitle),
        actions: _gameState.isGameStarted
            ? [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppConstants.chipRadius),
                  ),
                  child: Text(
                    'ROUND ${_gameState.currentRound.toString().padLeft(2, '0')}',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      color: AppConstants.onBackground,
                    ),
                  ),
                ),
              ]
            : null,
      ),
      body: mainContent,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppConstants.primary.withValues(alpha: 0.9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        clipBehavior: Clip.antiAlias,
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.scoreboard), label: 'SCORING'),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: 'HISTORY'),
            BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'NEW GAME'),
            BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: 'GRAPH'),
          ],
        ),
      ),
    );
  }
}
