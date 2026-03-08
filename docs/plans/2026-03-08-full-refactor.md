# Full Codebase Refactor Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Refactor the 1,833-line god file into clean, separated modules while fixing all 24 identified issues from the code audit.

**Architecture:** Extract screens into individual files, merge duplicate widgets into a single parameterized component, replace findAncestorStateOfType with callbacks, consolidate GameState JSON parsing, fix memory leaks. Maintain backward-compatible re-exports from main.dart so existing tests pass unchanged.

**Tech Stack:** Flutter 3.7+, Dart 3.7+, SharedPreferences, Firebase, fl_chart

---

## Pre-existing test failures (DO NOT try to fix these — they were broken before refactor):
- "App should start with New Game screen" — expects text that doesn't exist
- "Default sign toggle shows correct icon" — landscape/portrait mismatch

## Test baseline: 12 pass, 2 fail (pre-existing)

---

### Task 1: Fix GameState model

**Files:**
- Modify: `lib/models/game_state.dart`
- Modify: `lib/utils/constants.dart`

**Changes:**
- Add `static const int maxPlayers = 4` to AppConstants
- Replace all hardcoded `4` in GameState with `AppConstants.maxPlayers`
- Remove duplicate `fromJson()` factory — make `load()` call `fromJson()` internally
- Fix `fromJson` error fallback from `GameState.newGame(0)` to `GameState()`
- Clean up AI comments ("Add this new method")

**Verify:** `flutter test test/unit_tests/game_state_test.dart` — all pass

---

### Task 2: Create directory structure and extract app.dart

**Files:**
- Create: `lib/app.dart`
- Create: `lib/screens/` directory
- Create: `lib/widgets/` directory

**Changes:**
- Extract `ScoreKeeperApp` class from main.dart into `lib/app.dart`
- Move `score_chart.dart` to `lib/widgets/score_chart.dart`
- Update import in any file that references score_chart

---

### Task 3: Extract screens into separate files

**Files:**
- Create: `lib/screens/main_screen.dart`
- Create: `lib/screens/scoring_screen.dart`
- Create: `lib/screens/history_screen.dart`
- Create: `lib/screens/new_game_screen.dart`
- Create: `lib/screens/graph_screen.dart`

**Changes:**
- Move each class to its own file with proper imports
- HistoryScreen: Add `onRevertToRound` callback parameter, remove `findAncestorStateOfType` hack
- MainScreen: Pass revert callback to HistoryScreen
- NewGameScreen: Remove Scaffold wrapper (parent already provides one)
- main.dart: Reduce to Firebase init + runApp + re-exports for test compat

---

### Task 4: Merge PlayerScoreRow and PlayerScoreCard

**Files:**
- Create: `lib/widgets/player_score_input.dart`
- Modify: `lib/screens/scoring_screen.dart`

**Changes:**
- Create single `PlayerScoreInput` widget with `isLandscape` parameter
- Absorb both portrait (Row) and landscape (Card) layouts
- Remove `onScoreChanged` empty callback from interface
- Remove `errorMessage` (never populated)

---

### Task 5: Deduplicate history views and graph legends

**Files:**
- Modify: `lib/screens/history_screen.dart`
- Modify: `lib/screens/graph_screen.dart`

**Changes:**
- Merge `_buildPortraitHistoryView` and `_buildLandscapeHistoryView` into single `_buildHistoryTable` with spacing params
- Make HistoryScreen a StatelessWidget (no local state)
- Merge portrait/landscape legend into one method

---

### Task 6: Clean up main.dart, constants, dead code

**Files:**
- Modify: `lib/main.dart`
- Modify: `lib/utils/constants.dart`
- Modify: `lib/screens/main_screen.dart`
- Modify: `lib/screens/scoring_screen.dart`

**Changes:**
- main.dart: Only Firebase init, runApp, and re-exports
- Remove `dart:async` and `dart:isolate` unused imports from screens
- Remove commented-out flutter_svg import
- Remove `appVersion` from constants (loaded dynamically)
- Remove duplicate `tabNames` in `_logNavEvent` — use `_tabTitles`
- Fix memory leak: dispose old controllers before reinitializing in `didUpdateWidget`
- Fix empty `_updateScoreBoxes` setState

---

### Task 7: Fix pre-existing test failures

**Files:**
- Modify: `test/widget_test.dart`
- Modify: `test/widget_tests/scoring_screen_test.dart`

**Changes:**
- Fix "Select Number of Players" → match actual UI text
- Fix default sign toggle test to work in default test viewport

---

### Task 8: Final verification

**Verify:** `flutter test` — all tests pass
**Verify:** `flutter analyze` — no issues
**Commit**
