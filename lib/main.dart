import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:flutter_svg/flutter_svg.dart'; // Removed unused import
import 'package:package_info_plus/package_info_plus.dart'; // Import package info
import 'firebase_options.dart';
import 'score_chart.dart';
import 'models/game_state.dart';
import 'utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized(); // <-- MOVE THIS LINE
  
  runZonedGuarded(() async {
    // Ensure bindings are initialized WITHIN the zone
    WidgetsFlutterBinding.ensureInitialized(); // <-- TO HERE
    
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Initialize Crashlytics
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    
    // Add 2 second delay for native initialization
    await Future.delayed(const Duration(seconds: 2));
    
    runApp(ScoreKeeperApp(
      analytics: FirebaseAnalytics.instance,
    ));
  }, (error, stackTrace) {
    print('Global error caught: $error');
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });
}

class ScoreKeeperApp extends StatelessWidget {
  final FirebaseAnalytics? analytics;
  
  const ScoreKeeperApp({
    super.key, 
    required this.analytics,
  });
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      restorationScopeId: 'score_keeper_app',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppConstants.primaryColor),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      shortcuts: {
        ...WidgetsApp.defaultShortcuts,
      },
      home: MainScreen(analytics: analytics),
    );
  }
}

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
  late int _selectedIndex;
  late GameState _gameState;
  bool _isLoading = true;
  String _appVersion = ''; // State variable for version
  String _buildNumber = ''; // State variable for build number

  @override
  void initState() {
    super.initState();
    _selectedIndex = 2; // Default for initial load
    _loadGameState();
    _loadPackageInfo(); // Load version info
  }

  Future<void> _loadGameState() async {
    try {
      final gameState = await GameState.load();
      setState(() {
        _gameState = gameState;
        _isLoading = false;
        _selectedIndex = _gameState.isGameStarted ? 0 : 2;
      });
    } catch (e, stackTrace) {
      print('Critical error loading state: $e\n$stackTrace');
      // Reset to clean state
      setState(() {
        _gameState = GameState(isGameStarted: false);
        _isLoading = false;
        _selectedIndex = 2;
      });
      // Clear any corrupted preferences
      await (await SharedPreferences.getInstance()).remove('gameState');
    }
  }

  Future<void> _loadPackageInfo() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
      });
    } catch (e) {
      debugPrint('Error loading package info: $e');
      // Handle error if needed, maybe set default values
      setState(() {
        _appVersion = '?.?.?';
        _buildNumber = '?';
      });
    }
  }

  void _startNewGame(int playerCount) {
    if (_gameState.isGameStarted && _gameState.scoreHistory.isNotEmpty) {
      _showNewGameConfirmationDialog(playerCount);
    } else {
      _confirmStartNewGame(playerCount);
    }
    
    // Log the event
    _logNavEvent(0);
  }

  void _showNewGameConfirmationDialog(int playerCount) {
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
              _confirmStartNewGame(playerCount);
            },
            child: const Text('Start New Game'),
          ),
        ],
      ),
    );
  }

  void _confirmStartNewGame(int playerCount) {
    setState(() {
      _gameState = GameState.newGame(playerCount);
      _selectedIndex = 0;
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
    
    // Log the event
    _logNavEvent(0);
  }

  void _updateDefaultSignPreference(bool isNegative) {
    setState(() {
      _gameState.setDefaultNegative(isNegative);
    });
    _gameState.save();
  }

  final List<String> _tabTitles = ['Home', 'History', 'New Game', 'Graph'];

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      // Track the navigation event
      _logNavEvent(index);
      
      setState(() {
        _selectedIndex = index;
      });
      
      // Your existing navigation logic...
    }
  }
  
  void _logNavEvent(int index) {
    if (widget.analytics == null) return;
    
    // Define tab names
    final List<String> tabNames = ['Home', 'History', 'New Game', 'Graph'];
    
    // Log the event
    widget.analytics!.logEvent(
      name: 'nav_click',
      parameters: {
        'tab_name': tabNames[index],
        'previous_tab': _selectedIndex < tabNames.length ? tabNames[_selectedIndex] : 'Unknown',
      },
    );
    
    print('Firebase Analytics: Logged navigation to ${tabNames[index]}');
  }

  // Method to handle the actual reset logic
  void _resetCurrentGame() {
    setState(() {
      _gameState.currentScores = List.filled(4, 0); // Reset scores for all potential player slots
      _gameState.scoreHistory.clear();
      _gameState.currentRound = 1;
      // _gameState.playerNames and _gameState.playerCount remain unchanged
      _selectedIndex = 0; // Switch to Home tab after reset
    });
    _gameState.save(); // Save the reset state
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Game Reset! Scores and history cleared.'),
        backgroundColor: Colors.orange,
      ),
    );
  }
  
  // Method to show the confirmation dialog before resetting
  void _showResetConfirmationDialog() {
    // Ensure there's actually a game to reset
    if (!_gameState.isGameStarted || _gameState.scoreHistory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No game progress to reset.'),
          backgroundColor: Colors.blueGrey,
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
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              _resetCurrentGame(); // Perform the reset
            },
            child: const Text('Reset Game'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Decide which main content to show
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
          onPlayerNameChanged: _updatePlayerName,
          onScoresSubmitted: _submitRoundScores,
          onDefaultSignChanged: _updateDefaultSignPreference,
        ),
        HistoryScreen(
          playerCount: _gameState.playerCount,
          playerNames: _gameState.playerNames,
          scoreHistory: _gameState.scoreHistory,
        ),
        NewGameScreen(
          onNewGame: _startNewGame,
          onResetGame: _showResetConfirmationDialog,
          currentGameState: _gameState,
          showAppBar: false,
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
      mainContent = screens[_selectedIndex];
    }

    // Correct AppBar Title determination (Ensure it handles the case when game isn't started)
    String appBarTitle = _gameState.isGameStarted
        ? _tabTitles[_selectedIndex]
        : AppConstants.appName; // Or a suitable title like 'New Game'

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(appBarTitle), // Use the determined title
      ),
      body: mainContent, 
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: _tabTitles[0]),
          BottomNavigationBarItem(icon: const Icon(Icons.history), label: _tabTitles[1]),
          BottomNavigationBarItem(icon: const Icon(Icons.add), label: _tabTitles[2]),
          BottomNavigationBarItem(icon: const Icon(Icons.bar_chart), label: _tabTitles[3]),
        ],
      ),
    );
  }
}

// Scoring Screen
class ScoringScreen extends StatefulWidget {
  final int playerCount;
  final List<String> playerNames;
  final List<int> currentScores;
  final int currentRound;
  final bool defaultNegative;
  final Function(int, String) onPlayerNameChanged;
  final Function(List<int>) onScoresSubmitted;
  final Function(bool) onDefaultSignChanged;

  const ScoringScreen({
    super.key,
    required this.playerCount,
    required this.playerNames,
    required this.currentScores,
    required this.currentRound,
    required this.defaultNegative,
    required this.onPlayerNameChanged,
    required this.onScoresSubmitted,
    required this.onDefaultSignChanged,
  });

  @override
  State<ScoringScreen> createState() => _ScoringScreenState();
}

class _ScoringScreenState extends State<ScoringScreen> {
  late List<TextEditingController> _scoreControllers;
  late List<bool> _isNegativeScore;
  final List<String> _errorMessages = List.filled(4, '');
  final GlobalKey _scoreBoxKey = GlobalKey();
  late bool _defaultNegative;
  late List<FocusNode> _scoreFocusNodes;

  @override
  void initState() {
    super.initState();
    _defaultNegative = widget.defaultNegative;
    _initializeControllers();
  }

  @override
  void didUpdateWidget(ScoringScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playerCount != widget.playerCount) {
      _initializeControllers();
    }
  }

  void _initializeControllers() {
    _scoreControllers = List.generate(4, (index) => TextEditingController());
    _isNegativeScore = List.generate(4, (index) => _defaultNegative);
    _scoreFocusNodes = List.generate(4, (index) => FocusNode());
    
    for (var controller in _scoreControllers) {
      controller.addListener(_updateScoreBoxes);
    }
  }

  void _updateScoreBoxes() {
    setState(() {
      // Just trigger a rebuild to update the score boxes
    });
  }

  @override
  void dispose() {
    for (var controller in _scoreControllers) {
      controller.removeListener(_updateScoreBoxes);
      controller.dispose();
    }
    for (var focusNode in _scoreFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  bool _validateScores() {
    bool isValid = true;
    List<String> errorMessages = [];

    for (int i = 0; i < widget.playerCount; i++) {
      // Only validate if text has been entered
      if (_scoreControllers[i].text.isNotEmpty) {
        try {
          int score = int.parse(_scoreControllers[i].text);
          if (score < 0) {
            // This check might be redundant if using the toggle, but good practice
            errorMessages.add('${widget.playerNames[i]}: Use +/- toggle for negative scores');
            isValid = false;
          }
        } catch (e) {
          errorMessages.add('${widget.playerNames[i]}: Invalid number');
          isValid = false;
        }
      }
      // Empty score field is now considered valid during validation
    }

    if (!isValid) {
      String errorMessage = errorMessages.length > 1
          ? 'Please fix invalid score entries'
          : errorMessages.first;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }

    return isValid;
  }

  void _submitScores() {
    if (!_validateScores()) {
      return; // Error message already shown in _validateScores
    }

    List<int> roundScores = List.filled(4, 0);

    for (int i = 0; i < widget.playerCount; i++) {
      int score = 0; // Default to 0 if empty
      if (_scoreControllers[i].text.isNotEmpty) {
        score = int.parse(_scoreControllers[i].text); // Validation ensures this parse succeeds
      }

      if (_isNegativeScore[i]) {
        score = -score;
      }

      roundScores[i] = score;
      _scoreControllers[i].clear();
    }

    widget.onScoresSubmitted(roundScores);
    setState(() {
      _isNegativeScore = List.generate(4, (index) => _defaultNegative);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Scores for round ${widget.currentRound} submitted'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Calculate total score for all players
  int _calculateTotalScore() {
    int total = 0;
    for (int i = 0; i < widget.playerCount; i++) {
      total += widget.currentScores[i];
    }
    return total;
  }

  // Calculate current round score based on input fields
  int _calculateCurrentRoundScore() {
    int total = 0;
    for (int i = 0; i < widget.playerCount; i++) {
      if (_scoreControllers[i].text.isNotEmpty) {
        try {
          int score = int.parse(_scoreControllers[i].text);
          if (_isNegativeScore[i]) {
            score = -score;
          }
          total += score;
        } catch (e) {
          // Skip invalid entries
        }
      }
    }
    return total;
  }

  void _toggleScoreSign(int index) {
    setState(() {
      _isNegativeScore[index] = !_isNegativeScore[index];
      _scoreFocusNodes[index].requestFocus();
      _updateScoreBoxes();
    });
  }

  void _toggleDefaultSign() {
    setState(() {
      _defaultNegative = !_defaultNegative;
      // Update all empty score fields to the new default
      for (int i = 0; i < widget.playerCount; i++) {
        if (_scoreControllers[i].text.isEmpty) {
          _isNegativeScore[i] = _defaultNegative;
        }
      }
      // Persist the preference to GameState
      widget.onDefaultSignChanged(_defaultNegative);
    });
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;
    
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          // This makes sure any text field that has focus will lose it
          FocusScope.of(context).unfocus();
        },
        behavior: HitTestBehavior.translucent,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Compact Round indicator at the top
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Round ${widget.currentRound}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              
              // Main scrollable content (player rows and submit button)
              Expanded(
                child: isLandscape
                    ? _buildLandscapeLayout()
                    : _buildPortraitLayout(),
              ),
              
              // Submit button (scrolls with content)
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _submitScores,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(46), // Slightly smaller
                ),
                child: const Text('Submit Round Scores'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreBox(int score, Color backgroundColor) {
    return Container(
      height: 40.0, // Smaller height for score box
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$score',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildPortraitLayout() {
    return Column(
      children: [
        // Column headers with smaller font
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Row(
            children: [
              const Expanded(
                flex: 3,
                child: Text(
                  'Player',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                flex: 2,
                child: Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                flex: 2,
                child: Text(
                  'Round',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 8),
              // Default sign toggle button
              SizedBox(
                width: 48,
                child: GestureDetector(
                  onTap: _toggleDefaultSign,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _defaultNegative ? Icons.remove_circle : Icons.add_circle,
                        color: _defaultNegative ? AppConstants.negativeScoreColor : AppConstants.positiveScoreColor,
                        size: 20,
                      ),
                      Text(
                        'Default',
                        style: TextStyle(
                          fontSize: 10,
                          color: _defaultNegative ? AppConstants.negativeScoreColor : AppConstants.positiveScoreColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Thinner divider
        const Padding(
          padding: EdgeInsets.only(bottom: 4.0),
          child: Divider(height: 1, thickness: 1),
        ),
        // Player rows
        Expanded(
          child: ListView.builder(
            itemCount: widget.playerCount,
            itemBuilder: (context, index) {
              return PlayerScoreRow(
                playerIndex: index,
                playerName: widget.playerNames[index],
                currentScore: widget.currentScores[index],
                scoreController: _scoreControllers[index],
                scoreFocusNode: _scoreFocusNodes[index],
                isNegative: _isNegativeScore[index],
                errorMessage: _errorMessages[index],
                onPlayerNameChanged: widget.onPlayerNameChanged,
                onToggleSign: () => _toggleScoreSign(index),
                onScoreChanged: (_) {}, // No need for this now, we have listeners
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout() {
    return Column(
      children: [
        // Add default sign toggle at the top in landscape mode
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                'Default Sign: ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              GestureDetector(
                onTap: _toggleDefaultSign,
                child: Row(
                  children: [
                    Icon(
                      _defaultNegative ? Icons.remove_circle : Icons.add_circle,
                      color: _defaultNegative ? AppConstants.negativeScoreColor : AppConstants.positiveScoreColor,
                      size: 24,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _defaultNegative ? 'Negative' : 'Positive',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _defaultNegative ? AppConstants.negativeScoreColor : AppConstants.positiveScoreColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ),
        // Column headers for landscape are inside the grid items
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: widget.playerCount,
            itemBuilder: (context, index) {
              return PlayerScoreCard(
                playerIndex: index,
                playerName: widget.playerNames[index],
                currentScore: widget.currentScores[index],
                scoreController: _scoreControllers[index],
                scoreFocusNode: _scoreFocusNodes[index],
                isNegative: _isNegativeScore[index],
                errorMessage: _errorMessages[index],
                onPlayerNameChanged: widget.onPlayerNameChanged,
                onToggleSign: () => _toggleScoreSign(index),
                onScoreChanged: (_) {}, // No need for this now, we have listeners
              );
            },
          ),
        ),
      ],
    );
  }
}

// Player Score Row Widget
class PlayerScoreRow extends StatefulWidget {
  final int playerIndex;
  final String playerName;
  final int currentScore;
  final TextEditingController scoreController;
  final FocusNode scoreFocusNode;
  final bool isNegative;
  final String errorMessage;
  final Function(int, String) onPlayerNameChanged;
  final VoidCallback onToggleSign;
  final Function(String) onScoreChanged;

  const PlayerScoreRow({
    super.key,
    required this.playerIndex,
    required this.playerName,
    required this.currentScore,
    required this.scoreController,
    required this.scoreFocusNode,
    required this.isNegative,
    this.errorMessage = '',
    required this.onPlayerNameChanged,
    required this.onToggleSign,
    required this.onScoreChanged,
  });

  @override
  State<PlayerScoreRow> createState() => _PlayerScoreRowState();
}

class _PlayerScoreRowState extends State<PlayerScoreRow> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.playerName);
  }

  @override
  void didUpdateWidget(PlayerScoreRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playerName != widget.playerName) {
      _nameController.text = widget.playerName;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tapping outside text fields
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.translucent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: AppConstants.playerRowHeight,
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Player Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                      controller: _nameController,
                      onChanged: (value) => widget.onPlayerNameChanged(widget.playerIndex, value),
                      onTap: () {
                        // Select all text when field is tapped
                        _nameController.selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: _nameController.text.length,
                        );
                      },
                      textInputAction: TextInputAction.done,
                      onEditingComplete: () => FocusScope.of(context).unfocus(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: AppConstants.playerRowHeight,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${widget.currentScore}',
                        style: TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.bold,
                          color: widget.currentScore < 0 ? AppConstants.negativeScoreColor : AppConstants.positiveScoreColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: AppConstants.playerRowHeight,
                    child: TextField(
                      controller: widget.scoreController,
                      focusNode: widget.scoreFocusNode,
                      decoration: InputDecoration(
                        labelText: 'Score',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.grey,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: widget.isNegative ? AppConstants.negativeScoreColor : AppConstants.positiveScoreColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: widget.isNegative ? AppConstants.negativeScoreColor : AppConstants.positiveScoreColor,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        errorText: widget.errorMessage.isNotEmpty ? widget.errorMessage : null,
                        alignLabelWithHint: true,
                        floatingLabelAlignment: FloatingLabelAlignment.center,
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: widget.onScoreChanged,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: widget.isNegative ? AppConstants.negativeScoreColor : AppConstants.positiveScoreColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: AppConstants.playerRowHeight,
                  width: 44, // Give button a defined width
                  child: InkWell( // Use InkWell for tap effect
                    onTap: widget.onToggleSign,
                    child: Container(
                      decoration: BoxDecoration(
                        color: widget.isNegative ? AppConstants.negativeScoreColor.withOpacity(0.8) : AppConstants.positiveScoreColor.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12), // Match TextField rounding
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/icon/plus_minus.png', // Path to your PNG
                          width: 24, 
                          height: 24,
                          fit: BoxFit.contain,
                          semanticLabel: 'Toggle Score Sign',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (widget.errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0, left: 8.0),
                child: Text(
                  widget.errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Add a new PlayerScoreCard widget for landscape orientation
class PlayerScoreCard extends StatefulWidget {
  final int playerIndex;
  final String playerName;
  final int currentScore;
  final TextEditingController scoreController;
  final FocusNode scoreFocusNode;
  final bool isNegative;
  final String errorMessage;
  final Function(int, String) onPlayerNameChanged;
  final VoidCallback onToggleSign;
  final Function(String) onScoreChanged;

  const PlayerScoreCard({
    super.key,
    required this.playerIndex,
    required this.playerName,
    required this.currentScore,
    required this.scoreController,
    required this.scoreFocusNode,
    required this.isNegative,
    this.errorMessage = '',
    required this.onPlayerNameChanged,
    required this.onToggleSign,
    required this.onScoreChanged,
  });

  @override
  State<PlayerScoreCard> createState() => _PlayerScoreCardState();
}

class _PlayerScoreCardState extends State<PlayerScoreCard> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.playerName);
  }

  @override
  void didUpdateWidget(PlayerScoreCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playerName != widget.playerName) {
      _nameController.text = widget.playerName;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double inputHeight = AppConstants.playerRowHeight - 15; // Slightly smaller for card layout
    
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.translucent,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: inputHeight,
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Player Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                  controller: _nameController,
                  onChanged: (value) => widget.onPlayerNameChanged(widget.playerIndex, value),
                  onTap: () {
                    // Select all text when field is tapped
                    _nameController.selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: _nameController.text.length,
                    );
                  },
                  textInputAction: TextInputAction.done,
                  onEditingComplete: () => FocusScope.of(context).unfocus(),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: inputHeight,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${widget.currentScore}',
                          style: TextStyle(
                            fontSize: 16, 
                            fontWeight: FontWeight.bold,
                            color: widget.currentScore < 0 ? AppConstants.negativeScoreColor : AppConstants.positiveScoreColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: inputHeight,
                      child: TextField(
                        controller: widget.scoreController,
                        focusNode: widget.scoreFocusNode,
                        decoration: InputDecoration(
                          labelText: 'Score',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.grey,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: widget.isNegative ? AppConstants.negativeScoreColor : AppConstants.positiveScoreColor,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: widget.isNegative ? AppConstants.negativeScoreColor : AppConstants.positiveScoreColor,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          errorText: widget.errorMessage.isNotEmpty ? widget.errorMessage : null,
                          alignLabelWithHint: true,
                          floatingLabelAlignment: FloatingLabelAlignment.center,
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: widget.onScoreChanged,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: widget.isNegative ? AppConstants.negativeScoreColor : AppConstants.positiveScoreColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: inputHeight,
                    width: 44, // Give button a defined width
                    child: InkWell( // Use InkWell for tap effect
                      onTap: widget.onToggleSign,
                      child: Container(
                        decoration: BoxDecoration(
                          color: widget.isNegative ? AppConstants.negativeScoreColor.withOpacity(0.8) : AppConstants.positiveScoreColor.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12), // Match TextField rounding
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/icon/plus_minus.png', // Path to your PNG
                            width: 20, 
                            height: 20,
                            fit: BoxFit.contain,
                            semanticLabel: 'Toggle Score Sign',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (widget.errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, left: 8.0),
                  child: Text(
                    widget.errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// History Screen
class HistoryScreen extends StatefulWidget {
  final int playerCount;
  final List<String> playerNames;
  final List<List<int>> scoreHistory;

  const HistoryScreen({
    super.key,
    required this.playerCount,
    required this.playerNames,
    required this.scoreHistory,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    if (widget.scoreHistory.isEmpty) {
      return const Center(
        child: Text('No game history yet'),
      );
    }

    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Center(
            child: Text(
              'Score History',
              style: AppConstants.headingStyle,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: isLandscape
                ? _buildLandscapeHistoryView()
                : _buildPortraitHistoryView(),
          ),
        ],
      ),
    );
  }

  Widget _buildPortraitHistoryView() {
    // Calculate column widths based on player count to ensure full width usage
    final screenWidth = MediaQuery.of(context).size.width - 32; // Account for padding
    
    // Use smaller horizontal margins and spacing
    const horizontalMargin = 8.0;
    const columnSpacing = 8.0;
    
    // Reduce the round column width slightly
    const roundColumnWidth = 40.0;
    
    // Calculate remaining width available for player columns
    final availableWidth = screenWidth - (2 * horizontalMargin);
    final totalSpacing = columnSpacing * widget.playerCount; // Spacing between columns
    final playerColumnsWidth = availableWidth - roundColumnWidth - totalSpacing;
    final playerColumnWidth = playerColumnsWidth / widget.playerCount;
    
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            child: DataTable(
              columnSpacing: columnSpacing,
              horizontalMargin: horizontalMargin,
              headingRowHeight: 40,
              dataRowMinHeight: 36,
              dataRowMaxHeight: 48,
              columns: [
                DataColumn(
                  label: Container(
                    width: roundColumnWidth,
                    alignment: Alignment.center,
                    child: const Text(
                      'Rnd',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                for (int i = 0; i < widget.playerCount; i++)
                  DataColumn(
                    label: Container(
                      width: playerColumnWidth,
                      alignment: Alignment.center,
                      child: Text(
                        widget.playerNames[i],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
              rows: List.generate(
                widget.scoreHistory.length,
                (index) {
                  final roundNumber = index + 1;
                  final isLatestRound = index == widget.scoreHistory.length - 1;
                  
                  return DataRow(
                    color: isLatestRound
                        ? WidgetStateProperty.all(AppConstants.highlightColor)
                        : null,
                    cells: [
                      DataCell(
                        Container(
                          width: roundColumnWidth,
                          alignment: Alignment.center,
                          child: Text('$roundNumber'),
                        ),
                        onLongPress: () => _showRevertConfirmation(context, roundNumber),
                      ),
                      for (int i = 0; i < widget.playerCount; i++)
                        DataCell(
                          Container(
                            width: playerColumnWidth,
                            alignment: Alignment.center,
                            child: Text(
                              '${widget.scoreHistory[index][i]}',
                              style: TextStyle(
                                color: widget.scoreHistory[index][i] < 0 ? AppConstants.negativeScoreColor : AppConstants.positiveScoreColor,
                                fontWeight: isLatestRound ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                          onLongPress: () => _showRevertConfirmation(context, roundNumber),
                        ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLandscapeHistoryView() {
    // Calculate column widths based on player count to ensure full width usage
    final screenWidth = MediaQuery.of(context).size.width - 32; // Account for padding
    
    // Use smaller horizontal margins and spacing
    const horizontalMargin = 12.0;
    const columnSpacing = 12.0;
    
    // Reduce the round column width slightly for consistency
    const roundColumnWidth = 50.0;
    
    // Calculate remaining width available for player columns
    final availableWidth = screenWidth - (2 * horizontalMargin);
    final totalSpacing = columnSpacing * widget.playerCount; // Spacing between columns
    final playerColumnsWidth = availableWidth - roundColumnWidth - totalSpacing;
    final playerColumnWidth = playerColumnsWidth / widget.playerCount;
    
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            child: DataTable(
              columnSpacing: columnSpacing,
              horizontalMargin: horizontalMargin,
              headingRowHeight: 48,
              dataRowMinHeight: 40,
              dataRowMaxHeight: 56,
              columns: [
                DataColumn(
                  label: Container(
                    width: roundColumnWidth,
                    alignment: Alignment.center,
                    child: const Text(
                      'Round',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                for (int i = 0; i < widget.playerCount; i++)
                  DataColumn(
                    label: Container(
                      width: playerColumnWidth,
                      alignment: Alignment.center,
                      child: Text(
                        widget.playerNames[i],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
              rows: List.generate(
                widget.scoreHistory.length,
                (index) {
                  final roundNumber = index + 1;
                  final isLatestRound = index == widget.scoreHistory.length - 1;
                  
                  return DataRow(
                    color: isLatestRound
                        ? WidgetStateProperty.all(AppConstants.highlightColor)
                        : null,
                    cells: [
                      DataCell(
                        Container(
                          width: roundColumnWidth,
                          alignment: Alignment.center,
                          child: Text('$roundNumber'),
                        ),
                        onLongPress: () => _showRevertConfirmation(context, roundNumber),
                      ),
                      for (int i = 0; i < widget.playerCount; i++)
                        DataCell(
                          Container(
                            width: playerColumnWidth,
                            alignment: Alignment.center,
                            child: Text(
                              '${widget.scoreHistory[index][i]}',
                              style: TextStyle(
                                color: widget.scoreHistory[index][i] < 0 ? AppConstants.negativeScoreColor : AppConstants.positiveScoreColor,
                                fontWeight: isLatestRound ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                          onLongPress: () => _showRevertConfirmation(context, roundNumber),
                        ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _showRevertConfirmation(BuildContext context, int roundNumber) {
    final int totalRounds = widget.scoreHistory.length;
    
    if (roundNumber == totalRounds) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This is already the latest round.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Revert to Round $roundNumber?'),
          content: Text(
            'This will delete all subsequent rounds (${roundNumber + 1}-$totalRounds).\n\n'
            'The game will continue from Round ${roundNumber + 1}.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _revertToRound(roundNumber);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('REVERT'),
            ),
          ],
        );
      },
    );
  }

  void _revertToRound(int roundNumber) {
    // Get reference to the parent MainScreen state
    final mainScreenState = context.findAncestorStateOfType<_MainScreenState>();
    if (mainScreenState != null) {
      // Update the game state in the parent
      mainScreenState.setState(() {
        final gameState = mainScreenState._gameState;
        gameState.revertToRound(roundNumber);
      });
      
      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Game reverted to Round $roundNumber. Now playing Round ${roundNumber + 1}.'),
          duration: const Duration(seconds: 3),
        ),
      );
      
      // Navigate to scoring screen
      mainScreenState.setState(() {
        mainScreenState._selectedIndex = 0; // Switch to scoring tab
      });
    }
  }
}

// New Game Screen
class NewGameScreen extends StatelessWidget {
  final Function(int) onNewGame;
  final Function()? onResetGame; 
  final GameState? currentGameState; 
  final bool showAppBar;
  final String appVersion; // Add version parameter
  final String buildNumber; // Add build number parameter

  const NewGameScreen({
    super.key,
    required this.onNewGame,
    this.onResetGame,
    this.currentGameState,
    this.showAppBar = true,
    required this.appVersion, // Make required
    required this.buildNumber, // Make required
  });

  @override
  Widget build(BuildContext context) {
    // Determine if the reset section should be shown
    final bool canReset = currentGameState != null && currentGameState!.isGameStarted;
    
    // Get player names string for the reset description
    String playerNamesString = "";
    if (canReset) {
      playerNamesString = currentGameState!.playerNames
          .sublist(0, currentGameState!.playerCount)
          .join(', ');
    }
    
    return Scaffold(
      appBar: showAppBar ? AppBar(title: const Text('New Game Setup')) : null,
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            // --- Reset Current Game Section (Conditional) ---
            if (canReset)
              Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reset Current Game',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Keep the current players ($playerNamesString) but clear all scores to start from Round 1.',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: onResetGame, // Call the callback passed from MainScreen
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange, // Distinct color for reset
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(46),
                      ),
                      child: const Text('Reset Game'),
                    ),
                    const Divider(height: 40, thickness: 1),
                  ],
                ),
              ),
            
            // --- Start New Game Section ---
            const Text(
              'Start New Game',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Select the number of players for a completely new game. This will erase any current game progress.',
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            // Player count buttons
            Column(
              children: List.generate(3, (index) {
                int count = index + 2;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ElevatedButton(
                    onPressed: () => onNewGame(count),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(46),
                    ),
                    child: Text('$count Players'),
                  ),
                );
              }),
            ),
            // Use Spacer to push version to bottom only if Reset section is NOT shown
            if (!canReset) const Spacer(), 
            // Add extra fixed space only if Reset section IS shown
            if (canReset) const SizedBox(height: 32.0), // Adjust height as needed
            // Version Info Display
            Padding(
              padding: const EdgeInsets.only(top: 16.0), // Keep existing top padding
              child: Center( // Center the text
                child: Text(
                  'Version: $appVersion ($buildNumber)', 
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[400], // Light gray color
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Graph Screen
class GraphScreen extends StatelessWidget {
  final int playerCount;
  final List<String> playerNames;
  final List<List<int>> scoreHistory;
  final List<int> currentScores;

  const GraphScreen({
    super.key,
    required this.playerCount,
    required this.playerNames,
    required this.scoreHistory,
    required this.currentScores,
  });

  @override
  Widget build(BuildContext context) {
    if (scoreHistory.isEmpty) {
      return const Center(
        child: Text('No game data to display'),
      );
    }

    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Score Progression',
            style: AppConstants.headingStyle,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ScoreChart(
              playerCount: playerCount,
              playerNames: playerNames,
              scoreHistory: scoreHistory,
            ),
          ),
          const SizedBox(height: 16),
          isLandscape
              ? _buildLandscapeLegend()
              : _buildPortraitLegend(),
        ],
      ),
    );
  }

  Widget _buildPortraitLegend() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 8,
      children: [
        for (int i = 0; i < playerCount; i++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16,
                height: 16,
                color: _getPlayerColor(i),
              ),
              const SizedBox(width: 4),
              Text(playerNames[i]),
            ],
          ),
      ],
    );
  }

  Widget _buildLandscapeLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < playerCount; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  color: _getPlayerColor(i),
                ),
                const SizedBox(width: 4),
                Text(playerNames[i]),
              ],
            ),
          ),
      ],
    );
  }

  Color _getPlayerColor(int index) {
    return AppConstants.playerColors[index % AppConstants.playerColors.length];
  }
}
