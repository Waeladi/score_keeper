import 'package:flutter/material.dart';
import '../utils/constants.dart';

class HistoryScreen extends StatelessWidget {
  final int playerCount;
  final List<String> playerNames;
  final List<List<int>> scoreHistory;
  final Function(int roundNumber) onRevertToRound;

  const HistoryScreen({
    super.key,
    required this.playerCount,
    required this.playerNames,
    required this.scoreHistory,
    required this.onRevertToRound,
  });

  @override
  Widget build(BuildContext context) {
    if (scoreHistory.isEmpty) {
      return const Center(child: Text('No game history yet'));
    }

    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Center(
            child: Text('Score History', style: AppConstants.headingStyle),
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildHistoryTable(context, isLandscape: isLandscape)),
        ],
      ),
    );
  }

  Widget _buildHistoryTable(BuildContext context, {required bool isLandscape}) {
    final screenWidth = MediaQuery.of(context).size.width - 32;
    final horizontalMargin = isLandscape ? 12.0 : 8.0;
    final columnSpacing = isLandscape ? 12.0 : 8.0;
    final roundColumnWidth = isLandscape ? 50.0 : 40.0;

    final availableWidth = screenWidth - (2 * horizontalMargin);
    final totalSpacing = columnSpacing * playerCount;
    final playerColumnWidth = (availableWidth - roundColumnWidth - totalSpacing) / playerCount;

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            child: DataTable(
              columnSpacing: columnSpacing,
              horizontalMargin: horizontalMargin,
              headingRowHeight: isLandscape ? 48 : 40,
              dataRowMinHeight: isLandscape ? 40 : 36,
              dataRowMaxHeight: isLandscape ? 56 : 48,
              columns: [
                DataColumn(
                  label: Container(
                    width: roundColumnWidth,
                    alignment: Alignment.center,
                    child: Text(
                      isLandscape ? 'Round' : 'Rnd',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                for (int i = 0; i < playerCount; i++)
                  DataColumn(
                    label: Container(
                      width: playerColumnWidth,
                      alignment: Alignment.center,
                      child: Text(
                        playerNames[i],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
              rows: List.generate(
                scoreHistory.length,
                (index) {
                  final roundNumber = index + 1;
                  final isLatestRound = index == scoreHistory.length - 1;

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
                      for (int i = 0; i < playerCount; i++)
                        DataCell(
                          Container(
                            width: playerColumnWidth,
                            alignment: Alignment.center,
                            child: Text(
                              '${scoreHistory[index][i]}',
                              style: TextStyle(
                                color: scoreHistory[index][i] < 0
                                    ? AppConstants.negativeScoreColor
                                    : AppConstants.positiveScoreColor,
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
    final int totalRounds = scoreHistory.length;

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
            'The game will continue from Round ${roundNumber + 1}.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onRevertToRound(roundNumber);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('REVERT'),
            ),
          ],
        );
      },
    );
  }
}
