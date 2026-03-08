import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../utils/constants.dart';

class NewGameScreen extends StatelessWidget {
  final Function(int) onNewGame;
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
  Widget build(BuildContext context) {
    final bool canReset = currentGameState != null && currentGameState!.isGameStarted;

    String playerNamesString = "";
    if (canReset) {
      playerNamesString = currentGameState!.playerNames
          .sublist(0, currentGameState!.playerCount)
          .join(', ');
    }

    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    onPressed: onResetGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(46),
                    ),
                    child: const Text('Reset Game'),
                  ),
                  const Divider(height: 40, thickness: 1),
                ],
              ),
            ),
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
          if (!canReset) const Spacer(),
          if (canReset) const SizedBox(height: 32.0),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Center(
              child: Text(
                'Version: $appVersion ($buildNumber)',
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
