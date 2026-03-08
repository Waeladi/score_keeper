import 'package:flutter/material.dart';
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
      return const Center(child: Text('No game data to display'));
    }

    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text('Score Progression', style: AppConstants.headingStyle),
          const SizedBox(height: 16),
          Expanded(
            child: ScoreChart(
              playerCount: playerCount,
              playerNames: playerNames,
              scoreHistory: scoreHistory,
            ),
          ),
          const SizedBox(height: 16),
          _buildLegend(isLandscape: isLandscape),
        ],
      ),
    );
  }

  Widget _buildLegend({required bool isLandscape}) {
    final items = List.generate(playerCount, (i) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: isLandscape ? 16.0 : 0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              color: AppConstants.playerColors[i % AppConstants.playerColors.length],
            ),
            const SizedBox(width: 4),
            Text(playerNames[i]),
          ],
        ),
      );
    });

    if (isLandscape) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: items,
      );
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 8,
      children: items,
    );
  }
}
