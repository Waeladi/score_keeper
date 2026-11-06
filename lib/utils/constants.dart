import 'package:flutter/material.dart';

class AppConstants {
  // App information
  static const String appName = 'Game Scores';

  // Game rules
  static const int maxPlayers = 4;

  // === Vibrant Forest Palette ===
  // Primary greens
  static const Color primary = Color(0xFF266829);
  static const Color primaryDim = Color(0xFF185C1E);
  static const Color onPrimary = Color(0xFFD1FFC8);
  static const Color primaryContainer = Color(0xFFB2FAA9);
  static const Color onPrimaryContainer = Color(0xFF1F6223);

  // Secondary (Deep Amethyst)
  static const Color secondary = Color(0xFF594ABA);
  static const Color onSecondary = Color(0xFFF5F0FF);
  static const Color secondaryContainer = Color(0xFFD3CCFF);
  static const Color onSecondaryContainer = Color(0xFF4433A5);

  // Tertiary (Teal accents)
  static const Color tertiary = Color(0xFF00656F);
  static const Color tertiaryContainer = Color(0xFF10EAFE);

  // Surfaces
  static const Color surface = Color(0xFFDEFFE2);
  static const Color surfaceBright = Color(0xFFDEFFE2);
  static const Color surfaceDim = Color(0xFFA0E4B1);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFCAFDD4);
  static const Color surfaceContainer = Color(0xFFBEF5C9);
  static const Color surfaceContainerHigh = Color(0xFFB5F0C2);
  static const Color surfaceContainerHighest = Color(0xFFACECBB);
  static const Color surfaceTint = Color(0xFF266829);

  // On-surface
  static const Color onSurface = Color(0xFF0C361D);
  static const Color onSurfaceVariant = Color(0xFF3B6447);
  static const Color inverseSurface = Color(0xFF001205);
  static const Color inverseOnSurface = Color(0xFF7CA785);
  static const Color inversePrimary = Color(0xFFB2FAA9);

  // Outline
  static const Color outline = Color(0xFF568061);
  static const Color outlineVariant = Color(0xFF8CB795);

  // Error
  static const Color error = Color(0xFFB02500);
  static const Color errorContainer = Color(0xFFF95630);
  static const Color onError = Color(0xFFFFEFEC);

  // Background (the outer green)
  static const Color background = Color(0xFF5DA059);
  static const Color onBackground = Color(0xFFFFFFFF);

  // Per-player colors, shared by avatars and graph lines
  static const List<Color> playerColors = [
    primary,
    secondary,
    tertiary,
    error,
  ];

  // Validation
  static const int maxScoreValue = 999999;

  // Layout
  static const double outerMargin = 18.0;  // ~2.25rem from design
  static const double cardRadius = 12.0;   // xl from design
  static const double chipRadius = 9999.0; // full/pill
} 