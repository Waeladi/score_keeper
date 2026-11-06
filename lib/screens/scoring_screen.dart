import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';
import '../widgets/player_score_input.dart';

class ScoringScreen extends StatefulWidget {
  final int playerCount;
  final List<String> playerNames;
  final List<int> currentScores;
  final int currentRound;
  final bool defaultNegative;
  final bool lowScoreWins;
  final Function(int, String) onPlayerNameChanged;
  final Function(List<int>) onScoresSubmitted;
  final Function(bool) onDefaultSignChanged;
  final Function(bool) onLowScoreWinsChanged;

  const ScoringScreen({
    super.key,
    required this.playerCount,
    required this.playerNames,
    required this.currentScores,
    required this.currentRound,
    required this.defaultNegative,
    required this.lowScoreWins,
    required this.onPlayerNameChanged,
    required this.onScoresSubmitted,
    required this.onDefaultSignChanged,
    required this.onLowScoreWinsChanged,
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
    if (oldWidget.defaultNegative != widget.defaultNegative) {
      _defaultNegative = widget.defaultNegative;
    }
    if (oldWidget.playerCount != widget.playerCount) {
      _disposeControllers();
      _initializeControllers();
    } else if (!identical(oldWidget.currentScores, widget.currentScores) ||
        (oldWidget.currentRound != widget.currentRound &&
            widget.currentRound != oldWidget.currentRound + 1)) {
      // New game / reset (new scores list) or revert (round jumped back):
      // pending entries belong to a round that no longer exists, so drop them.
      _clearEntries();
    }
  }

  void _clearEntries() {
    for (var controller in _scoreControllers) {
      controller.clear();
    }
    _isNegativeScore = List.generate(
      AppConstants.maxPlayers,
      (index) => _defaultNegative,
    );
  }

  void _initializeControllers() {
    _scoreControllers = List.generate(
      AppConstants.maxPlayers,
      (index) => TextEditingController(),
    );
    _isNegativeScore = List.generate(
      AppConstants.maxPlayers,
      (index) => _defaultNegative,
    );
    _scoreFocusNodes = List.generate(
      AppConstants.maxPlayers,
      (index) => FocusNode(),
    );

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
            errorMessages.add(
              '${widget.playerNames[i]}: Use +/- toggle for negative scores',
            );
          }
        } catch (e) {
          errorMessages.add('${widget.playerNames[i]}: Invalid number');
        }
      }
    }

    if (errorMessages.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessages.length > 1
                ? 'Please fix invalid score entries'
                : errorMessages.first,
          ),
          backgroundColor: AppConstants.error,
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
      _isNegativeScore = List.generate(
        AppConstants.maxPlayers,
        (index) => _defaultNegative,
      );
    });

    _scoreFocusNodes[0].requestFocus();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Round ${widget.currentRound} submitted'),
        backgroundColor: AppConstants.primary,
      ),
    );
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

  // Indexes of every player holding the best total (more than one on a tie).
  List<int> _getLeaderIndexes() {
    final scores = widget.currentScores.take(widget.playerCount);
    final best =
        widget.lowScoreWins
            ? scores.reduce((a, b) => a < b ? a : b)
            : scores.reduce((a, b) => a > b ? a : b);
    return [
      for (int i = 0; i < widget.playerCount; i++)
        if (widget.currentScores[i] == best) i,
    ];
  }

  String _displayName(int index) =>
      widget.playerNames[index].isNotEmpty
          ? widget.playerNames[index]
          : 'Player ${index + 1}';

  void _toggleLowScoreWins() {
    final lowScoreWins = !widget.lowScoreWins;
    widget.onLowScoreWinsChanged(lowScoreWins);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            lowScoreWins ? 'Lowest score now leads' : 'Highest score now leads',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  int _calculateCurrentRoundTotal() {
    int total = 0;
    for (int i = 0; i < widget.playerCount; i++) {
      if (_scoreControllers[i].text.isNotEmpty) {
        try {
          int score = int.parse(_scoreControllers[i].text);
          if (_isNegativeScore[i]) score = -score;
          total += score;
        } catch (_) {}
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final hasEntries = _scoreControllers
        .take(widget.playerCount)
        .any((controller) => controller.text.isNotEmpty);

    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.outerMargin,
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Dashboard summary cards
              _buildDashboardCards(),
              const SizedBox(height: 16),
              // Section header
              _buildSectionHeader(),
              const SizedBox(height: 8),
              // Player list
              Expanded(
                child:
                    isLandscape
                        ? _buildLandscapeLayout()
                        : _buildPortraitLayout(),
              ),
              // Submit CTA: only once at least one score has been entered
              if (hasEntries) ...[
                const SizedBox(height: 8),
                _buildSubmitSection(),
              ],
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCards() {
    final leaders = _getLeaderIndexes();
    final leaderName = switch (leaders.length) {
      1 => _displayName(leaders[0]),
      2 => '${_displayName(leaders[0])} & ${_displayName(leaders[1])}',
      _ => 'Tied',
    };
    final leaderScore = widget.currentScores[leaders.first];
    final roundTotal = _calculateCurrentRoundTotal();

    // IntrinsicHeight + stretch keeps both cards the same height.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Leader card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppConstants.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                border: const Border(
                  bottom: BorderSide(color: AppConstants.primary, width: 4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'LEADER',
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                            color: AppConstants.onSurfaceVariant,
                          ),
                        ),
                      ),
                      _buildWinRuleChip(),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    leaderName,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppConstants.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '$leaderScore',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppConstants.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Round total card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppConstants.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppConstants.cardRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ROUND TOTAL',
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      color: AppConstants.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Round ${widget.currentRound}',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppConstants.onSurface,
                    ),
                  ),
                  Text(
                    roundTotal >= 0 ? '+$roundTotal' : '$roundTotal',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color:
                          roundTotal < 0
                              ? AppConstants.secondary
                              : AppConstants.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWinRuleChip() {
    final low = widget.lowScoreWins;
    return Semantics(
      button: true,
      label:
          low
              ? 'Lowest score wins. Tap to switch to highest.'
              : 'Highest score wins. Tap to switch to lowest.',
      excludeSemantics: true,
      child: Material(
        color: AppConstants.surfaceContainerLow,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: _toggleLowScoreWins,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  low ? Icons.arrow_downward : Icons.arrow_upward,
                  size: 12,
                  color: AppConstants.primary,
                ),
                const SizedBox(width: 2),
                Text(
                  low ? 'LOW' : 'HIGH',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: AppConstants.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Active Players',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppConstants.onBackground,
          ),
        ),
        GestureDetector(
          onTap: _toggleDefaultSign,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppConstants.chipRadius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _defaultNegative
                      ? Icons.remove_circle_outline
                      : Icons.add_circle_outline,
                  size: 14,
                  color: AppConstants.onBackground,
                ),
                const SizedBox(width: 4),
                Text(
                  _defaultNegative ? 'Default -' : 'Default +',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.onBackground.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPortraitLayout() {
    return ListView.builder(
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
    );
  }

  Widget _buildLandscapeLayout() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
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
    );
  }

  Widget _buildSubmitSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ready for next round?',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppConstants.onBackground,
                ),
              ),
              Text(
                'Round ${widget.currentRound}',
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  color: AppConstants.onBackground.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: _submitScores,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppConstants.primaryDim, AppConstants.primary],
                ),
                borderRadius: BorderRadius.circular(AppConstants.chipRadius),
                boxShadow: [
                  BoxShadow(
                    color: AppConstants.onSurface.withValues(alpha: 0.15),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'SUBMIT',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
