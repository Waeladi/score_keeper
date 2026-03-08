import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/player_score_input.dart';

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
      _disposeControllers();
      _initializeControllers();
    }
  }

  void _initializeControllers() {
    _scoreControllers = List.generate(AppConstants.maxPlayers, (index) => TextEditingController());
    _isNegativeScore = List.generate(AppConstants.maxPlayers, (index) => _defaultNegative);
    _scoreFocusNodes = List.generate(AppConstants.maxPlayers, (index) => FocusNode());

    for (var controller in _scoreControllers) {
      controller.addListener(_onScoreChanged);
    }
  }

  void _disposeControllers() {
    for (var controller in _scoreControllers) {
      controller.removeListener(_onScoreChanged);
      controller.dispose();
    }
    for (var focusNode in _scoreFocusNodes) {
      focusNode.dispose();
    }
  }

  void _onScoreChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  bool _validateScores() {
    List<String> errorMessages = [];

    for (int i = 0; i < widget.playerCount; i++) {
      if (_scoreControllers[i].text.isNotEmpty) {
        try {
          int score = int.parse(_scoreControllers[i].text);
          if (score < 0) {
            errorMessages.add('${widget.playerNames[i]}: Use +/- toggle for negative scores');
          }
        } catch (e) {
          errorMessages.add('${widget.playerNames[i]}: Invalid number');
        }
      }
    }

    if (errorMessages.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessages.length > 1
              ? 'Please fix invalid score entries'
              : errorMessages.first),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return false;
    }

    return true;
  }

  void _submitScores() {
    if (!_validateScores()) return;

    List<int> roundScores = List.filled(AppConstants.maxPlayers, 0);

    for (int i = 0; i < widget.playerCount; i++) {
      int score = 0;
      if (_scoreControllers[i].text.isNotEmpty) {
        score = int.parse(_scoreControllers[i].text);
      }
      if (_isNegativeScore[i]) {
        score = -score;
      }
      roundScores[i] = score;
      _scoreControllers[i].clear();
    }

    widget.onScoresSubmitted(roundScores);
    setState(() {
      _isNegativeScore = List.generate(AppConstants.maxPlayers, (index) => _defaultNegative);
    });

    _scoreFocusNodes[0].requestFocus();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Scores for round ${widget.currentRound} submitted'),
        backgroundColor: Colors.green,
      ),
    );
  }

  int _calculateTotalScore() {
    int total = 0;
    for (int i = 0; i < widget.playerCount; i++) {
      total += widget.currentScores[i];
    }
    return total;
  }

  int _calculateCurrentRoundScore() {
    int total = 0;
    for (int i = 0; i < widget.playerCount; i++) {
      if (_scoreControllers[i].text.isNotEmpty) {
        try {
          int score = int.parse(_scoreControllers[i].text);
          if (_isNegativeScore[i]) score = -score;
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
    });
  }

  void _toggleDefaultSign() {
    setState(() {
      _defaultNegative = !_defaultNegative;
      for (int i = 0; i < widget.playerCount; i++) {
        if (_scoreControllers[i].text.isEmpty) {
          _isNegativeScore[i] = _defaultNegative;
        }
      }
      widget.onDefaultSignChanged(_defaultNegative);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Round ${widget.currentRound}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: isLandscape ? _buildLandscapeLayout() : _buildPortraitLayout(),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _submitScores,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(46),
                ),
                child: const Text('Submit Round Scores'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryScoreCard(String title, int score) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey),
          ),
          Text(
            '$score',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: score < 0 ? AppConstants.negativeScoreColor : AppConstants.positiveScoreColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultSignToggle({bool compact = false}) {
    final icon = Icon(
      _defaultNegative ? Icons.remove_circle : Icons.add_circle,
      color: _defaultNegative ? AppConstants.negativeScoreColor : AppConstants.positiveScoreColor,
      size: compact ? 20 : 24,
    );

    if (compact) {
      return SizedBox(
        width: 48,
        child: GestureDetector(
          onTap: _toggleDefaultSign,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
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
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text('Default Sign: ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        GestureDetector(
          onTap: _toggleDefaultSign,
          child: Row(
            children: [
              icon,
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
    );
  }

  Widget _buildSummaryRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Expanded(child: _buildSummaryScoreCard('Running Total', _calculateTotalScore())),
          const SizedBox(width: 12),
          Expanded(child: _buildSummaryScoreCard('Round Total', _calculateCurrentRoundScore())),
        ],
      ),
    );
  }

  Widget _buildPortraitLayout() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Row(
            children: [
              const Expanded(
                flex: 3,
                child: Text('Player', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
              ),
              const SizedBox(width: 8),
              const Expanded(
                flex: 2,
                child: Text('Total', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
              ),
              const SizedBox(width: 8),
              const Expanded(
                flex: 2,
                child: Text('Round', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
              ),
              const SizedBox(width: 8),
              _buildDefaultSignToggle(compact: true),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 4.0),
          child: Divider(height: 1, thickness: 1),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: widget.playerCount,
            itemBuilder: (context, index) {
              return PlayerScoreInput(
                playerIndex: index,
                playerName: widget.playerNames[index],
                currentScore: widget.currentScores[index],
                scoreController: _scoreControllers[index],
                scoreFocusNode: _scoreFocusNodes[index],
                isNegative: _isNegativeScore[index],
                onPlayerNameChanged: widget.onPlayerNameChanged,
                onToggleSign: () => _toggleScoreSign(index),
              );
            },
          ),
        ),
        _buildSummaryRow(),
      ],
    );
  }

  Widget _buildLandscapeLayout() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: _buildDefaultSignToggle(),
        ),
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
              return PlayerScoreInput(
                playerIndex: index,
                playerName: widget.playerNames[index],
                currentScore: widget.currentScores[index],
                scoreController: _scoreControllers[index],
                scoreFocusNode: _scoreFocusNodes[index],
                isNegative: _isNegativeScore[index],
                isLandscape: true,
                onPlayerNameChanged: widget.onPlayerNameChanged,
                onToggleSign: () => _toggleScoreSign(index),
              );
            },
          ),
        ),
        _buildSummaryRow(),
      ],
    );
  }
}
