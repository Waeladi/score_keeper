import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/main_screen.dart';
import 'utils/constants.dart';

class ScoreKeeperApp extends StatelessWidget {
  final FirebaseAnalytics? analytics;

  const ScoreKeeperApp({
    super.key,
    required this.analytics,
  });

  @override
  Widget build(BuildContext context) {
    final headlineTextTheme = GoogleFonts.spaceGroteskTextTheme();
    final bodyTextTheme = GoogleFonts.manropeTextTheme();

    // Merge: headlines from Space Grotesk, body/labels from Manrope
    final textTheme = bodyTextTheme.copyWith(
      displayLarge: headlineTextTheme.displayLarge,
      displayMedium: headlineTextTheme.displayMedium,
      displaySmall: headlineTextTheme.displaySmall,
      headlineLarge: headlineTextTheme.headlineLarge,
      headlineMedium: headlineTextTheme.headlineMedium,
      headlineSmall: headlineTextTheme.headlineSmall,
      titleLarge: headlineTextTheme.titleLarge,
      titleMedium: headlineTextTheme.titleMedium,
    );

    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppConstants.primary,
      onPrimary: AppConstants.onPrimary,
      primaryContainer: AppConstants.primaryContainer,
      onPrimaryContainer: AppConstants.onPrimaryContainer,
      secondary: AppConstants.secondary,
      onSecondary: AppConstants.onSecondary,
      secondaryContainer: AppConstants.secondaryContainer,
      onSecondaryContainer: AppConstants.onSecondaryContainer,
      tertiary: AppConstants.tertiary,
      tertiaryContainer: AppConstants.tertiaryContainer,
      error: AppConstants.error,
      onError: AppConstants.onError,
      errorContainer: AppConstants.errorContainer,
      onErrorContainer: Color(0xFF520C00),
      surface: AppConstants.surface,
      onSurface: AppConstants.onSurface,
      onSurfaceVariant: AppConstants.onSurfaceVariant,
      outline: AppConstants.outline,
      outlineVariant: AppConstants.outlineVariant,
      inverseSurface: AppConstants.inverseSurface,
      onInverseSurface: AppConstants.inverseOnSurface,
      inversePrimary: AppConstants.inversePrimary,
      surfaceTint: AppConstants.surfaceTint,
      surfaceContainerLowest: AppConstants.surfaceContainerLowest,
      surfaceContainerLow: AppConstants.surfaceContainerLow,
      surfaceContainer: AppConstants.surfaceContainer,
      surfaceContainerHigh: AppConstants.surfaceContainerHigh,
      surfaceContainerHighest: AppConstants.surfaceContainerHighest,
      surfaceBright: AppConstants.surfaceBright,
      surfaceDim: AppConstants.surfaceDim,
    );

    return MaterialApp(
      title: AppConstants.appName,
      restorationScopeId: 'score_keeper_app',
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        textTheme: textTheme,
        scaffoldBackgroundColor: AppConstants.background,
        appBarTheme: AppBarTheme(
          backgroundColor: AppConstants.background,
          foregroundColor: AppConstants.onBackground,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: GoogleFonts.spaceGrotesk(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: AppConstants.onBackground,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppConstants.primary.withValues(alpha: 0.9),
          selectedItemColor: AppConstants.primaryContainer,
          unselectedItemColor: Colors.white.withValues(alpha: 0.7),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: GoogleFonts.manrope(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
          unselectedLabelStyle: GoogleFonts.manrope(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryDim,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.chipRadius),
            ),
            textStyle: GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppConstants.primary,
          contentTextStyle: GoogleFonts.manrope(color: AppConstants.onPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      ),
      home: MainScreen(analytics: analytics),
    );
  }
}
