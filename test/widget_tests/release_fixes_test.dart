import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:score_keeper/main.dart';
import 'package:score_keeper/widgets/number_pad.dart';

Widget _pad(TextEditingController controller) => MaterialApp(
      home: Scaffold(
        body: NumberPad(
          controller: controller,
          isNegative: false,
          onToggleSign: () {},
          onDone: () {},
        ),
      ),
    );

void main() {
  testWidgets('NumberPad replaces a lone leading zero', (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(_pad(controller));

    await tester.tap(find.text('0').last);
    await tester.tap(find.text('7'));
    expect(controller.text, '7');
  });

  testWidgets('NumberPad stops at maxScoreValue', (tester) async {
    final controller = TextEditingController(text: '999999');
    await tester.pumpWidget(_pad(controller));

    await tester.tap(find.text('1'));
    expect(controller.text, '999999');
  });

  testWidgets('Bundled fonts load with runtime fetching disabled', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    addTearDown(() => GoogleFonts.config.allowRuntimeFetching = true);

    await tester.pumpWidget(MaterialApp(
      home: Column(children: [
        Text('a', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900)),
        Text('b', style: GoogleFonts.manrope(fontWeight: FontWeight.w600)),
      ]),
    ));
    await GoogleFonts.pendingFonts();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Unsubmitted entry survives switching tabs', (tester) async {
    tester.view.physicalSize = const Size(600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const ScoreKeeperApp(analytics: null));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2 Players'));
    await tester.pumpAndSettle();

    // Last '0' on screen is Player 2's score-entry pill; enter 42 there.
    await tester.tap(find.text('0').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('4'));
    await tester.tap(find.text('2'));
    await tester.tap(find.text('DONE'));
    await tester.pumpAndSettle();
    expect(find.text('42'), findsOneWidget);

    await tester.tap(find.text('HISTORY'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('SCORING'));
    await tester.pumpAndSettle();

    expect(find.text('42'), findsOneWidget);
  });
}
