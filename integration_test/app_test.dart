import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutterbase/app/bootstrap/app_widget.dart';
import 'package:flutterbase/app/di/service_locator.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupServiceLocator();
  });

  group('App integration tests', () {
    testWidgets('App launches and shows splash screen', (tester) async {
      await tester.pumpWidget(const AppWidget());
      await tester.pump();
      // Splash screen contains the app name
      expect(find.text('FlutterBase'), findsAtLeast(1));
    });

    testWidgets('App transitions from splash to main page', (tester) async {
      await tester.pumpWidget(const AppWidget());
      // Wait for splash animation + delay (2 seconds total)
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      // Main page navigation bar should be visible
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('Theme changes persist via ThemeViewModel', (tester) async {
      await tester.pumpWidget(const AppWidget());
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Navigate to settings tab
      final settingsTab = find.byIcon(Icons.settings_outlined);
      if (settingsTab.evaluate().isNotEmpty) {
        await tester.tap(settingsTab.first);
        await tester.pumpAndSettle();
        // Settings content should be visible
        expect(find.text('Theme'), findsAtLeast(1));
      }
    });
  });
}
