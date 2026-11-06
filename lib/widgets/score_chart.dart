import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

class ScoreChart extends StatelessWidget {
  final int playerCount;
  final List<String> playerNames;
  final List<List<int>> scoreHistory;

  const ScoreChart({
    super.key,
    required this.playerCount,
    required this.playerNames,
    required this.scoreHistory,
  });

  @override
  Widget build(BuildContext context) {
    if (scoreHistory.isEmpty) {
      return const Center(child: Text('No data to display'));
    }

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    List<List<int>> cumulativeScores = [];
    List<int> runningTotals = List.filled(playerCount, 0);

    // Prepend starting point: all players at 0 before round 1
    cumulativeScores.add(List.filled(playerCount, 0));

    for (var roundScores in scoreHistory) {
      for (int i = 0; i < playerCount; i++) {
        runningTotals[i] += roundScores[i];
      }
      cumulativeScores.add(List.from(runningTotals));
    }

    int minScore = 0;
    int maxScore = 0;
    for (var roundTotal in cumulativeScores) {
      for (int i = 0; i < playerCount; i++) {
        if (roundTotal[i] < minScore) minScore = roundTotal[i];
        if (roundTotal[i] > maxScore) maxScore = roundTotal[i];
      }
    }
    minScore -= 10;
    maxScore += 10;

    // Thin out round labels so they don't overlap in long games (~8 max).
    final rounds = cumulativeScores.length - 1;
    final labelInterval = (rounds <= 8 ? 1 : (rounds / 8).ceil()).toDouble();

    final axisLabelStyle = GoogleFonts.manrope(
      color: AppConstants.onSurfaceVariant,
      fontWeight: FontWeight.w600,
      fontSize: isLandscape ? 10 : 11,
    );
    final gridLine = FlLine(
      color: AppConstants.outlineVariant.withValues(alpha: 0.4),
      strokeWidth: 1,
    );

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          verticalInterval: labelInterval,
          getDrawingHorizontalLine: (_) => gridLine,
          getDrawingVerticalLine: (_) => gridLine,
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                // Only show labels for integer positions (actual data points)
                if ((value - value.toInt()).abs() > 0.01) {
                  return const SizedBox.shrink();
                }
                final index = value.toInt();
                final label = index == 0 ? 'Start' : 'R$index';
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(label, style: axisLabelStyle),
                );
              },
              interval: labelInterval,
              reservedSize: isLandscape ? 24 : 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: axisLabelStyle,
                  textAlign: TextAlign.center,
                );
              },
              reservedSize: isLandscape ? 30 : 40,
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: const Border(
            left: BorderSide(color: AppConstants.outlineVariant),
            bottom: BorderSide(color: AppConstants.outlineVariant),
          ),
        ),
        minX: 0,
        maxX: cumulativeScores.length - 1.0,
        minY: minScore.toDouble(),
        maxY: maxScore.toDouble(),
        lineBarsData: List.generate(
          playerCount,
          (playerIndex) => LineChartBarData(
            spots: List.generate(
              cumulativeScores.length,
              (roundIndex) => FlSpot(
                roundIndex.toDouble(),
                cumulativeScores[roundIndex][playerIndex].toDouble(),
              ),
            ),
            isCurved: true,
            // Don't let the smoothed line dip/peak past real scores.
            preventCurveOverShooting: true,
            color:
                AppConstants.playerColors[playerIndex %
                    AppConstants.playerColors.length],
            barWidth: isLandscape ? 2 : 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: isLandscape ? 3 : 4,
                  color: barData.color ?? AppConstants.onSurface,
                  strokeWidth: 1,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(show: false),
          ),
        ),
      ),
    );
  }
}
