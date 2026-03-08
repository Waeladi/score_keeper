import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
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
    return MaterialApp(
      title: AppConstants.appName,
      restorationScopeId: 'score_keeper_app',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppConstants.primaryColor),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      home: MainScreen(analytics: analytics),
    );
  }
}
