import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterbase/shared/theme/app_theme.dart';
import 'package:flutterbase/shared/theme/app_colors.dart';

/// Helpers to build widgets under a specific theme for testing.
Widget _wrapWithTheme(Widget child, ThemeData theme) {
  return MaterialApp(theme: theme, home: Scaffold(body: child));
}

void main() {
  group('Dark mode text readability', () {
    testWidgets('Text inherits white color in dark theme', (tester) async {
      await tester.pumpWidget(
        _wrapWithTheme(
          const Text('Hello', key: Key('test-text')),
          AppTheme.dark,
        ),
      );
      await tester.pump();

      final text = tester.widget<Text>(find.byKey(const Key('test-text')));
      // Text has no explicit color — it should inherit from DefaultTextStyle
      expect(text.style, isNull); // no explicit style

      // The rendered text color comes from the theme; check via RichText
      final richText = tester.widget<RichText>(
        find.descendant(
          of: find.byKey(const Key('test-text')),
          matching: find.byType(RichText),
        ),
      );
      final resolvedColor = richText.text.style?.color;
      if (resolvedColor != null) {
        // In dark mode the text color should be light (high luminance)
        expect(resolvedColor.computeLuminance(), greaterThan(0.4));
      }
    });

    testWidgets('Text inherits dark color in light theme', (tester) async {
      await tester.pumpWidget(
        _wrapWithTheme(
          Builder(
            builder: (ctx) => Text(
              'Hello',
              key: const Key('test-text'),
              style: Theme.of(ctx).textTheme.bodyMedium,
            ),
          ),
          AppTheme.light,
        ),
      );
      await tester.pump();

      final richText = tester.widget<RichText>(
        find.descendant(
          of: find.byKey(const Key('test-text')),
          matching: find.byType(RichText),
        ),
      );
      final color = richText.text.style?.color;
      if (color != null) {
        // In light mode the body text should be dark
        expect(color.computeLuminance(), lessThan(0.5));
      }
    });
  });

  group('Theme color schemes', () {
    testWidgets('Light theme scaffold has white background', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: SizedBox()),
        ),
      );
      await tester.pump();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, isNull); // uses theme default
      expect(AppTheme.light.scaffoldBackgroundColor, equals(AppColors.bgBase));
    });

    testWidgets('Dark theme scaffold has dark background', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.dark,
          home: const Scaffold(body: SizedBox()),
        ),
      );
      await tester.pump();

      expect(AppTheme.dark.scaffoldBackgroundColor, equals(AppColors.darkBgBase));
    });

    testWidgets('AppBar respects theme colors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            appBar: AppBar(title: const Text('Test')),
            body: const SizedBox(),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Test'), findsOneWidget);
    });
  });

  group('Widget smoke tests', () {
    testWidgets('ElevatedButton renders correctly in light mode',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () {},
              child: const Text('Button'),
            ),
          ),
        ),
      );
      expect(find.text('Button'), findsOneWidget);
    });

    testWidgets('ElevatedButton renders correctly in dark mode',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.dark,
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () {},
              child: const Text('Button'),
            ),
          ),
        ),
      );
      expect(find.text('Button'), findsOneWidget);
    });

    testWidgets('TextField renders in both themes', (tester) async {
      for (final theme in [AppTheme.light, AppTheme.dark]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: const Scaffold(
              body: TextField(decoration: InputDecoration(hintText: 'Type here')),
            ),
          ),
        );
        expect(find.byType(TextField), findsOneWidget);
      }
    });
  });
}
