import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history,
                size: 48, color: AppConstants.onBackground.withValues(alpha: 0.7)),
            const SizedBox(height: 8),
            Text(
              'No rounds played yet',
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

    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppConstants.outerMargin, 12, AppConstants.outerMargin, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Score History',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppConstants.onBackground,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Long-press a round to revert to it',
              style: GoogleFonts.manrope(
                fontSize: 12,
                color: AppConstants.onBackground.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppConstants.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                ),
                child: _buildHistoryTable(context, isLandscape: isLandscape),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTable(BuildContext context, {required bool isLandscape}) {
    final screenWidth =
        MediaQuery.of(context).size.width - 2 * AppConstants.outerMargin;
    final horizontalMargin = isLandscape ? 12.0 : 8.0;
    final columnSpacing = isLandscape ? 12.0 : 8.0;
    final roundColumnWidth = isLandscape ? 50.0 : 40.0;

    final availableWidth = screenWidth - (2 * horizontalMargin);
    final totalSpacing = columnSpacing * playerCount;
    final playerColumnWidth = (availableWidth - roundColumnWidth - totalSpacing) / playerCount;

    final headerStyle = GoogleFonts.manrope(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 1,
      color: AppConstants.onSurfaceVariant,
    );

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            child: DataTable(
              columnSpacing: columnSpacing,
              horizontalMargin: horizontalMargin,
              headingRowHeight: isLandscape ? 48 : 44,
              dataRowMinHeight: isLandscape ? 40 : 36,
              dataRowMaxHeight: isLandscape ? 56 : 48,
              headingRowColor: WidgetStateProperty.all(AppConstants.surfaceContainerLow),
              dividerThickness: 0.5,
              columns: [
                DataColumn(
                  label: Container(
                    width: roundColumnWidth,
                    alignment: Alignment.center,
                    child: Text(isLandscape ? 'ROUND' : 'RND', style: headerStyle),
                  ),
                ),
                for (int i = 0; i < playerCount; i++)
                  DataColumn(
                    label: Container(
                      width: playerColumnWidth,
                      alignment: Alignment.center,
                      child: Text(
                        playerNames[i],
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppConstants.onSurface,
                        ),
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
                        ? WidgetStateProperty.all(AppConstants.primaryContainer)
                        : null,
                    cells: [
                      DataCell(
                        Container(
                          width: roundColumnWidth,
                          alignment: Alignment.center,
                          child: Text(
                            '$roundNumber',
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w700,
                              color: AppConstants.onSurfaceVariant,
                            ),
                          ),
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
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 15,
                                color: scoreHistory[index][i] < 0
                                    ? AppConstants.secondary
                                    : AppConstants.primary,
                                fontWeight: isLatestRound ? FontWeight.w700 : FontWeight.w500,
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
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onRevertToRound(roundNumber);
              },
              style: TextButton.styleFrom(foregroundColor: AppConstants.error),
              child: const Text('Revert'),
            ),
          ],
        );
      },
    );
  }
}
