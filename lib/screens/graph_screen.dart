import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';
import '../widgets/score_chart.dart';

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
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.leaderboard,
                size: 48, color: AppConstants.onBackground.withValues(alpha: 0.7)),
            const SizedBox(height: 8),
            Text(
              'Play a round to see the graph',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppConstants.onBackground,
              ),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppConstants.outerMargin, 12, AppConstants.outerMargin, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Score Progression',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppConstants.onBackground,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(4, 16, 16, 12),
                decoration: BoxDecoration(
                  color: AppConstants.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ScoreChart(
                        playerCount: playerCount,
                        playerNames: playerNames,
                        scoreHistory: scoreHistory,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildLegend(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 8,
      children: List.generate(playerCount, (i) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppConstants.playerColors[i % AppConstants.playerColors.length],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              playerNames[i],
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppConstants.onSurface,
              ),
            ),
          ],
        );
      }),
    );
  }
}
