/// Read-only snapshot of application version and build metadata.
///
/// Pure Dart class — no Flutter or infrastructure imports.
final class AppInfoDto {
  const AppInfoDto({
    required this.version,
    required this.buildNumber,
    required this.gitCommit,
    required this.gitCommitFull,
    required this.flutterVersion,
    required this.dartVersion,
    required this.buildDate,
    required this.isDebug,
  });

  /// Semantic version string from pubspec (e.g. "1.0.0").
  final String version;

  /// Git commit count used as build number (e.g. "26").
  final String buildNumber;

  /// Short Git commit hash (e.g. "f3c3fd3").
  final String gitCommit;

  /// Full Git commit hash.
  final String gitCommitFull;

  /// Flutter SDK version at build time.
  final String flutterVersion;

  /// Dart SDK version at build time.
  final String dartVersion;

  /// ISO-8601 timestamp of the build.
  final String buildDate;

  /// Whether this is a debug build.
  final bool isDebug;
}
