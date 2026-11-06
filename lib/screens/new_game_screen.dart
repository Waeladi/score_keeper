import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_state.dart';
import '../utils/constants.dart';

class NewGameScreen extends StatefulWidget {
  final Function(int playerCount, bool lowScoreWins) onNewGame;
  final Function()? onResetGame;
  final GameState? currentGameState;
  final String appVersion;
  final String buildNumber;

  const NewGameScreen({
    super.key,
    required this.onNewGame,
    this.onResetGame,
    this.currentGameState,
    required this.appVersion,
    required this.buildNumber,
  });

  @override
  State<NewGameScreen> createState() => _NewGameScreenState();
}

class _NewGameScreenState extends State<NewGameScreen> {
  // Starts from the current/last game's rule so regular low-score players
  // only have to pick it once.
  late bool _lowScoreWins = widget.currentGameState?.lowScoreWins ?? false;

  @override
  void didUpdateWidget(NewGameScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Follow changes made mid-game from the leader card chip.
    _lowScoreWins = widget.currentGameState?.lowScoreWins ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final bool canReset =
        widget.currentGameState != null && widget.currentGameState!.isGameStarted;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppConstants.outerMargin, 12, AppConstants.outerMargin, 16),
        children: [
          if (canReset) ...[
            _buildResetCard(),
            const SizedBox(height: 24),
          ],
          Text(
            'Start New Game',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppConstants.onBackground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose the number of players. This erases any current game progress.',
            style: GoogleFonts.manrope(
              fontSize: 13,
              color: AppConstants.onBackground.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 12),
          _buildWinningScoreSelector(),
          const SizedBox(height: 12),
          Row(
            children: [
              for (int count = 2; count <= AppConstants.maxPlayers; count++) ...[
                if (count > 2) const SizedBox(width: 12),
                Expanded(child: _buildPlayerCountTile(count)),
              ],
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Version: ${widget.appVersion} (${widget.buildNumber})',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 12,
              color: AppConstants.onBackground.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetCard() {
    final playerNames = widget.currentGameState!.playerNames
        .sublist(0, widget.currentGameState!.playerCount)
        .join(', ');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CURRENT GAME',
            style: GoogleFonts.manrope(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: AppConstants.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            playerNames,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppConstants.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Reset keeps these players and clears all scores back to Round 1.',
            style: GoogleFonts.manrope(
              fontSize: 13,
              color: AppConstants.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: widget.onResetGame,
              icon: const Icon(Icons.restart_alt),
              label: const Text('Reset Game'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppConstants.error,
                side: const BorderSide(color: AppConstants.error),
                minimumSize: const Size.fromHeight(48),
                shape: const StadiumBorder(),
                textStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWinningScoreSelector() {
    final labelStyle = GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700);
    return Row(
      children: [
        Text(
          'Winning score',
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppConstants.onBackground,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SegmentedButton<bool>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: false,
                icon: const Icon(Icons.arrow_upward, size: 16),
                label: Text('Highest', style: labelStyle),
              ),
              ButtonSegment(
                value: true,
                icon: const Icon(Icons.arrow_downward, size: 16),
                label: Text('Lowest', style: labelStyle),
              ),
            ],
            selected: {_lowScoreWins},
            onSelectionChanged: (selection) =>
                setState(() => _lowScoreWins = selection.first),
            style: SegmentedButton.styleFrom(
              backgroundColor: AppConstants.surfaceContainerLowest,
              foregroundColor: AppConstants.onSurfaceVariant,
              selectedBackgroundColor: AppConstants.primaryContainer,
              selectedForegroundColor: AppConstants.onPrimaryContainer,
              side: const BorderSide(color: AppConstants.outlineVariant),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerCountTile(int count) {
    return Semantics(
      button: true,
      label: '$count Players',
      excludeSemantics: true,
      child: Material(
        color: AppConstants.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          onTap: () => widget.onNewGame(count, _lowScoreWins),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Text(
                  '$count',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: AppConstants.primary,
                  ),
                ),
                Text(
                  'PLAYERS',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: AppConstants.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
