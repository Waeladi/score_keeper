# Testing Game Scores App

This directory contains tests for the Game Scores application.

## Types of Tests

### Unit Tests
Located in `test/unit_tests/`
- Test individual functions and classes
- Focus on business logic and data manipulation

### Widget Tests
Located in `test/widget_tests/`
- Test UI components and their interaction
- Verify widget behavior without needing a device/emulator

### Integration Tests
Located in `integration_test/`
- End-to-end tests that simulate actual user behavior
- Test the app as users would experience it

## Running Tests

### Run All Unit and Widget Tests
```bash
flutter test
```

### Run a Specific Test File
```bash
flutter test test/unit_tests/game_state_test.dart
flutter test test/widget_tests/scoring_screen_test.dart
```

### Run Integration Tests
Requires a connected device or emulator:
```bash
flutter test integration_test/app_test.dart
```

### Run All Tests with the Script
Make the script executable first:
```bash
chmod +x run_tests.sh
./run_tests.sh
```

## Writing New Tests

### Adding Unit Tests
- Create a new file in `test/unit_tests/`
- Test one class or function per file
- Focus on edge cases and expected behavior

### Adding Widget Tests
- Create a new file in `test/widget_tests/`
- Use `testWidgets` to test UI components
- Use `find` to locate widgets and `expect` to verify their properties

### Adding Integration Tests
- Modify or create new tests in `integration_test/app_test.dart`
- Simulate complete user flows
- Test interaction between different screens 