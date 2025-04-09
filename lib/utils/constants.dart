import 'package:flutter/material.dart';

class AppConstants {
  // App information
  static const String appName = 'Game Scores';
  static const String appVersion = '1.0.0';
  
  // Colors
  static const Color primaryColor = Colors.blue;
  static const Color accentColor = Colors.blueAccent;
  static const Color negativeScoreColor = Colors.red;
  static const Color positiveScoreColor = Colors.green;
  static const Color highlightColor = Color(0xFFE0F7E0); // Light green for highlighting
  
  // Score box colors
  static const Color totalScoreBoxColor = Color(0xFFE3F2FD); // Light blue
  static const Color roundScoreBoxColor = Color(0xFFE8F5E9); // Light green
  
  // Player colors for graph
  static const List<Color> playerColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
  ];
  
  // Text styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );
  
  static const TextStyle scoreBoxTitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle scoreBoxValueStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
  
  // Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 400);
  
  // Validation
  static const int maxScoreValue = 999999;
  static const int minScoreValue = -99999;
  
  // Layout
  static const double defaultPadding = 16.0;
  static const double playerRowHeight = 60.0;
  static const double scoreBoxHeight = 80.0;
} 