import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:score_keeper/main.dart' as app;
// Import for debugPrint

/// This test is only meant for diagnostic purposes
/// It prints out the widget tree to help debug tests
void main() {
  testWidgets('Diagnostic test - print widget tree', (WidgetTester tester) async {
    // Start the app
    app.main();
    
    // Wait for app to settle
    await tester.pumpAndSettle();
    
    // Print basic info
    debugPrint('\n==== DIAGNOSTIC INFORMATION ====');
    debugPrint('Screen size: ${tester.view.physicalSize}');
    
    // Print all text widgets
    debugPrint('\n==== TEXT WIDGETS ====');
    final textWidgets = find.byType(Text);
    if (textWidgets.evaluate().isEmpty) {
      debugPrint('No Text widgets found');
    } else {
      textWidgets.evaluate().forEach((element) {
        final widget = element.widget as Text;
        debugPrint('Text: "${widget.data}" - Style: ${widget.style}');
      });
    }
    
    // Print all buttons
    debugPrint('\n==== BUTTONS ====');
    final buttonWidgets = find.byType(ElevatedButton);
    if (buttonWidgets.evaluate().isEmpty) {
      debugPrint('No ElevatedButton widgets found');
    } else {
      buttonWidgets.evaluate().forEach((element) {
        final widget = element.widget as ElevatedButton;
        String buttonText = 'Unknown';
        if (widget.child is Text) {
          buttonText = (widget.child as Text).data ?? 'null';
        }
        debugPrint('Button with text: "$buttonText"');
      });
    }
    
    // Print AppBar if exists
    debugPrint('\n==== APP BAR ====');
    final appBar = find.byType(AppBar);
    if (appBar.evaluate().isEmpty) {
      debugPrint('No AppBar found');
    } else {
      final widget = appBar.evaluate().first.widget as AppBar;
      String title = 'Unknown';
      if (widget.title is Text) {
        title = (widget.title as Text).data ?? 'null';
      }
      debugPrint('AppBar title: "$title"');
    }
    
    // Print simplified widget tree
    debugPrint('\n==== SIMPLIFIED WIDGET TREE ====');
    final root = find.byType(MaterialApp);
    if (root.evaluate().isNotEmpty) {
      _printWidgetTree(root.evaluate().first, '', true);
    } else {
      debugPrint('No MaterialApp found');
    }
    
    debugPrint('\n==== END OF DIAGNOSTIC INFO ====');
    
    // This test doesn't assert anything, it's just for diagnostic purposes
    expect(true, true);
  });
}

/// Helper method to print a simplified widget tree
void _printWidgetTree(Element element, String prefix, bool isLast) {
  final widget = element.widget;
  final widgetType = widget.runtimeType.toString();
  
  String text = '';
  if (widget is Text) {
    text = ' (Text: "${widget.data}")';
  }
  
  debugPrint('$prefix${isLast ? '└── ' : '├── '}$widgetType$text');
  
  // Collect all children first
  final List<Element> children = [];
  element.visitChildren(children.add);
  
  // Then process them with index information
  for (int i = 0; i < children.length; i++) {
    final child = children[i];
    final isLastChild = i == children.length - 1;
    final newPrefix = prefix + (isLast ? '    ' : '│   ');
    
    _printWidgetTree(child, newPrefix, isLastChild);
  }
}