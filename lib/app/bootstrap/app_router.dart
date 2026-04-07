import 'package:flutter/material.dart';
import 'package:flutterbase/app/di/service_locator.dart';
import 'package:flutterbase/presentation/pages/main_page.dart';
import 'package:flutterbase/presentation/pages/splash_page.dart';
import 'package:flutterbase/presentation/pages/system/about_page.dart';
import 'package:flutterbase/presentation/pages/system/debug_page.dart';
import 'package:flutterbase/presentation/pages/system/licenses_page.dart';
import 'package:flutterbase/presentation/pages/system/logs_page.dart';
import 'package:flutterbase/shared/l10n/app_strings.dart';
import 'package:flutterbase/shared/logging/app_logger.dart';

/// Named route definitions.
class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String main = '/main';
  static const String about = '/about';
  static const String licenses = '/licenses';
  static const String debug = '/debug';
  static const String logs = '/logs';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    sl<AppLogger>().debug('[Router] → ${settings.name}');
    return switch (settings.name) {
      splash => MaterialPageRoute<void>(
          builder: (_) => const SplashPage(),
          settings: settings,
        ),
      main => MaterialPageRoute<void>(
          builder: (_) => const MainPage(),
          settings: settings,
        ),
      about => MaterialPageRoute<void>(
          builder: (_) => const AboutPage(),
          settings: settings,
        ),
      licenses => MaterialPageRoute<void>(
          builder: (_) => const LicensesPage(),
          settings: settings,
        ),
      debug => MaterialPageRoute<void>(
          builder: (_) => const DebugPage(),
          settings: settings,
        ),
      logs => MaterialPageRoute<void>(
          builder: (_) => const LogsPage(),
          settings: settings,
        ),
      _ => MaterialPageRoute<void>(
          builder: (_) => const _NotFoundPage(),
          settings: settings,
        ),
    };
  }
}

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.commonPageNotFound)),
      body: const Center(child: Text(AppStrings.commonNotFound)),
    );
  }
}
