#!/bin/bash

# Ensure the script exits if any command fails
set -e

echo "=== Running Unit Tests ==="
flutter test test/unit_tests/game_state_test.dart

echo "=== Running Widget Tests ==="
flutter test test/widget_tests/scoring_screen_test.dart

echo "=== Running Integration Tests ==="
# Note: For integration tests, you need a connected device or emulator
flutter test integration_test/app_test.dart

echo "=== All Tests Completed ===" 