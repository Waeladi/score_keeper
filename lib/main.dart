import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'app.dart';

export 'app.dart' show ScoreKeeperApp;
export 'screens/scoring_screen.dart' show ScoringScreen;
export 'screens/history_screen.dart' show HistoryScreen;
export 'screens/new_game_screen.dart' show NewGameScreen;
export 'screens/graph_screen.dart' show GraphScreen;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Fonts are bundled in assets/google_fonts; never download them at runtime.
  GoogleFonts.config.allowRuntimeFetching = false;

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  Isolate.current.addErrorListener(RawReceivePort((pair) async {
    final List<dynamic> errorAndStacktrace = pair;
    await FirebaseCrashlytics.instance.recordError(
      errorAndStacktrace.first,
      errorAndStacktrace.last,
      fatal: true,
    );
  }).sendPort);

  runApp(ScoreKeeperApp(
    analytics: FirebaseAnalytics.instance,
  ));
}
