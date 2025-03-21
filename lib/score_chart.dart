import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'utils/constants.dart';

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
      return const Center(
        child: Text('No data to display'),
      );
    }

    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    // Calculate cumulative scores for each round
    List<List<int>> cumulativeScores = [];
    List<int> runningTotals = List.filled(playerCount, 0);

    for (var roundScores in scoreHistory) {
      for (int i = 0; i < playerCount; i++) {
        runningTotals[i] += roundScores[i];
      }
      cumulativeScores.add(List.from(runningTotals));
    }

    // Find min and max scores for Y-axis scaling
    int minScore = 0;
    int maxScore = 0;

    for (var roundTotal in cumulativeScores) {
      for (int i = 0; i < playerCount; i++) {
        if (roundTotal[i] < minScore) minScore = roundTotal[i];
        if (roundTotal[i] > maxScore) maxScore = roundTotal[i];
      }
    }

    // Add some padding to the min/max for better visualization
    minScore = minScore - 10;
    maxScore = maxScore + 10;

    return Padding(
      padding: EdgeInsets.all(isLandscape ? 8.0 : 16.0),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'R${value.toInt() + 1}',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: isLandscape ? 10 : 12,
                      ),
                    ),
                  );
                },
                reservedSize: isLandscape ? 24 : 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: isLandscape ? 10 : 12,
                    ),
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
            border: Border.all(color: const Color(0xff37434d)),
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
              color: _getPlayerColor(playerIndex),
              barWidth: isLandscape ? 2 : 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: isLandscape ? 3 : 4,
                    color: barData.color ?? Colors.black,
                    strokeWidth: 1,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(show: false),
            ),
          ),
        ),
      ),
    );
  }

  Color _getPlayerColor(int index) {
    return AppConstants.playerColors[index % AppConstants.playerColors.length];
  }
} 