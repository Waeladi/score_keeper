# Card Score Keeper

A Flutter application for tracking player scores across multiple rounds in card games.

## Features

- **Player Management**: Select 2-4 players and customize player names
- **Score Tracking**: Add positive or negative scores for each round
- **History Tracking**: View a complete history of all rounds played
- **Data Visualization**: See score progression over time with an interactive graph
- **Game State Persistence**: Automatically saves game state between sessions

## Getting Started

### Prerequisites

- Flutter SDK (version 3.7.0 or higher)
- Dart SDK (version 3.0.0 or higher)
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone this repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the application

## Usage

1. **Starting a New Game**:
   - Select the number of players (2-4)
   - Customize player names (optional)

2. **Recording Scores**:
   - Enter scores for each player
   - Use the +/- toggle to indicate positive or negative scores
   - Submit the round to update totals

3. **Viewing History**:
   - Navigate to the History tab to see all previous rounds
   - The most recent round is highlighted

4. **Viewing Score Progression**:
   - Navigate to the Graph tab to see score trends over time
   - Each player's score is represented by a different colored line

## Dependencies

- `shared_preferences`: For persisting game state
- `fl_chart`: For score visualization

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Developed by Wael Apps

PRD - 
Create a mobile app for a card scoring app that allows users to track player scores across multiple rounds in a card game.

The key components of the app appear to be:
1. Player management (select number of players, name players)
2. Score tracking (add/modify scores each round)
3. History tracking (view past rounds)
4. Data visualization (graph of scores over time)
5. Game state persistence

I'll structure the requirements document with these sections:
- Application Overview
- Functional Requirements
- User Interface Requirements
- Data Management
- Non-Functional Requirements</think># Cards Scoring App: Requirements Document

## 1. Application Overview

The Cards Scoring application is a mobile scoring tool designed to track scores across multiple rounds of card games. It provides an intuitive interface for managing player information, recording scores, visualizing score progression, and maintaining game history. The app eliminates the need for manual score tracking on paper and offers real-time calculations and visualizations.

## 2. Functional Requirements

### 2.1 Player Management
- **REQ-PM-01**: Allow users to select the number of players (2, 3, or 4) at the start of a new game.
- **REQ-PM-02**: Support customizable player names with default values of "Player 1", "Player 2", etc.
- **REQ-PM-03**: Display only the active players based on the selected player count (hide unused player rows).
- **REQ-PM-04**: Persist player names across application restarts and navigation between tabs.
- **REQ-PM-05**: Allow users to continue an existing game when launching the app.

### 2.2 Score Entry and Calculation
- **REQ-SC-01**: Provide dedicated input fields for each player's score entry for each round.
- **REQ-SC-02**: Support both positive and negative scores via a toggle button.
- **REQ-SC-03**: Calculate and display running total scores for each player.
- **REQ-SC-04**: Provide a submit button to finalize scores for the current round.
- **REQ-SC-05**: Validate score entries to ensure they contain valid numerical values.
- **REQ-SC-06**: Highlight score changes visually to indicate increase or decrease.

### 2.3 Game History
- **REQ-GH-01**: Maintain a chronological history of all rounds played.
- **REQ-GH-02**: Display round number and scores for each player in a tabular format.
- **REQ-GH-03**: Highlight the most recent round visually (light green background).
- **REQ-GH-04**: Allow navigation to a dedicated history tab to view the complete score history.
- **REQ-GH-05**: Support hiding columns for inactive players (based on player count).

### 2.4 Data Visualization
- **REQ-DV-01**: Provide a line graph visualization showing score progression over rounds.
- **REQ-DV-02**: Assign distinct colors to each player's line in the graph.
- **REQ-DV-03**: Include player names in the graph legend.
- **REQ-DV-04**: Support proper scaling of the Y-axis to accommodate all score values.
- **REQ-DV-05**: Allow navigating to a dedicated graph visualization screen.

### 2.5 Game State Management
- **REQ-GM-01**: Automatically save game state after each round is submitted.
- **REQ-GM-02**: Restore the most recent game state when the app is relaunched.
- **REQ-GM-03**: Provide an option to start a new game, clearing previous game data.
- **REQ-GM-04**: Persist player count, player names, current scores, round number, and score history.

## 3. User Interface Requirements

### 3.1 Navigation
- **REQ-UI-01**: Implement tab-based navigation with Home (scoring), History, New Game, and Graph tabs.
- **REQ-UI-02**: Ensure fragments retain proper state when switching between tabs.

### 3.2 Player Rows
- **REQ-UI-03**: Each player row should contain:
  - Player name (editable text field)
  - Current total score display
  - New score input field
  - Toggle button for score sign (+/-)
- **REQ-UI-04**: Visual feedback for active/inactive status of player rows.

### 3.3 History View
- **REQ-UI-05**: Table format with headers showing player names.
- **REQ-UI-06**: Round numbers displayed in leftmost column.
- **REQ-UI-07**: Proper column alignment and spacing.
- **REQ-UI-08**: Latest round highlighted with a distinct background color.

### 3.4 Graph View
- **REQ-UI-09**: Full-screen line chart showing score progression.
- **REQ-UI-10**: Clear legend with player names.
- **REQ-UI-11**: Proper scale and axis labels.
- **REQ-UI-12**: Close button to return to the main interface.

### 3.5 Initial Setup
- **REQ-UI-13**: Player count selection screen at first launch.
- **REQ-UI-14**: Start game button to proceed to the main scoring screen.

## 4. Data Management

### 4.1 Data Structures
- **REQ-DM-01**: Maintain lists for player names, current scores, and score history.
- **REQ-DM-02**: Store score history as a nested list structure (list of rounds, each containing a list of player scores).

### 4.2 Persistence
- **REQ-DM-03**: Use SharedPreferences to save and restore game state.
- **REQ-DM-04**: Serialize complex data structures appropriately for storage.
- **REQ-DM-05**: Handle potential data corruption or format changes gracefully.

## 5. Non-Functional Requirements

### 5.1 Performance
- **REQ-NF-01**: The application should respond to user input within 100ms.
- **REQ-NF-02**: Score calculations and updates should be completed within 200ms.
- **REQ-NF-03**: Game state should be saved within 500ms of score submission.

### 5.2 Usability
- **REQ-NF-04**: The UI should be intuitive, requiring no tutorial for basic operation.
- **REQ-NF-05**: Text fields should support standard text input conventions.
- **REQ-NF-06**: Visual indicators should distinguish active elements from inactive ones.
- **REQ-NF-07**: The app should provide proper visual feedback for all user actions.

### 5.3 Reliability
- **REQ-NF-08**: The app should not lose data during normal operation or when suspended.
- **REQ-NF-09**: Text input controls should prevent common errors (like reversed text input).
- **REQ-NF-10**: The app should handle unexpected input gracefully without crashing.

### 5.4 Compatibility
- **REQ-NF-11**: Support Android and iOS
- **REQ-NF-12**: Support both portrait and landscape orientations with appropriate layouts.
- **REQ-NF-13**: Preserve state across configuration changes (rotation, theme changes).


