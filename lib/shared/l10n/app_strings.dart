/// Centralised English string resources.
/// All user-visible strings must come from this class — never hardcoded inline.
class AppStrings {
  AppStrings._();

  // ─── App ──────────────────────────────────────────────────────────────
  static const String appName = 'PointBook';
  static const String appDescription =
      'Point accumulation and consumption management app';

  // ─── Navigation ───────────────────────────────────────────────────────
  static const String navHome = 'Home';
  static const String navSearch = 'Search';
  static const String navSettings = 'Settings';

  // ─── Drawer ───────────────────────────────────────────────────────────
  static const String drawerSubtitle = 'Point accumulation & spending';
  static const String drawerClose = 'Close';
  static const String drawerAbout = 'About';
  static const String drawerLicenses = 'Licenses';
  static const String drawerDebug = 'Debug Info';
  static const String drawerLogs = 'Logs';

  // ─── Home tab ─────────────────────────────────────────────────────────
  static const String homeWelcomeTitle = 'Welcome';
  static const String homeWelcomeSubtitle = 'DADS Design System App';
  static const String homeCardTitle = 'DADS Design System';
  static const String homeCardBody =
      'This app is built following the Digital Agency Design System (DADS). '
      'It provides a consistent UI based on color tokens, typography, and spacing.';
  static const String homeComponentsTitle = 'Components';
  static const String homePrimaryButton = 'Primary Button';
  static const String homeSecondaryButton = 'Secondary Button';
  static const String homeTextFieldLabel = 'Text Input';
  static const String homeTextFieldHint = 'Enter text here';
  static const String homeListCardTitle = 'List Card';
  static const String homeListCardSubtitle = 'Subtitle text';
  static const String homeListCardItem2 = 'Item 2';

  // ─── Search tab ───────────────────────────────────────────────────────
  static const String searchFieldLabel = 'Search';
  static const String searchFieldHint = 'Enter keyword';
  static const String searchEmptyMessage = 'Enter a keyword to search';

  // ─── Settings tab ─────────────────────────────────────────────────────
  static const String settingsTitle = 'Settings';
  static const String settingsTheme = 'Theme';
  static const String settingsThemeSystem = 'System default';
  static const String settingsThemeLight = 'Light';
  static const String settingsThemeDark = 'Dark';
  static const String settingsAbout = 'About';
  static const String settingsLicenses = 'Licenses';
  static const String settingsDebug = 'Debug Info';
  static const String settingsLogs = 'Logs';

  // ─── Footer ───────────────────────────────────────────────────────────
  static const String footerAbout = 'About';
  static const String footerLicenses = 'Licenses';

  // ─── About page ───────────────────────────────────────────────────────
  static const String aboutTitle = 'About';
  static const String aboutVersion = 'Version';
  static const String aboutBuildNumber = 'Build Number';
  static const String aboutGitCommit = 'Git Commit';
  static const String aboutFlutterVersion = 'Flutter Version';
  static const String aboutDartVersion = 'Dart Version';
  static const String aboutDesignSystem = 'Design System';
  static const String aboutDesignSystemValue = 'DADS v2.10.3';
  static const String aboutPlatform = 'Platform';
  static const String aboutPlatformValue = 'Android / iOS';
  static const String aboutDesignSystemSectionTitle = 'Design System';
  static const String aboutDesignSystemBody =
      'This app is built following the Design System\nprovided by the Digital Agency of Japan (DADS).';
  static const String aboutDesignSystemLink = 'Official Design System Website';

  // ─── Debug page ───────────────────────────────────────────────────────
  static const String debugTitle = 'Debug Info';
  static const String debugWarning =
      'This page is for debug purposes only. Do not display in release builds.';
  static const String debugAppInfoSection = 'App Info';
  static const String debugThemeSection = 'Theme Info';
  static const String debugThemeMode = 'Theme Mode';
  static const String debugThemeModeDark = 'Dark Mode';
  static const String debugThemeModeLight = 'Light Mode';
  static const String debugPrimaryColor = 'Primary Color';
  static const String debugSurfaceColor = 'Surface Color';
  static const String debugActionsSection = 'Debug Actions';
  static const String debugClearLogs = 'Clear Logs';
  static const String debugClearLogsSuccess = 'Logs cleared';
  static const String debugClearCache = 'Clear Cache';
  static const String debugClearCacheSuccess = 'Cache cleared';
  static const String debugTestCrash = 'Test Crash';
  static const String debugTestCrashTitle = 'Test Crash';
  static const String debugTestCrashBody =
      'Crash the app for testing purposes?';
  static const String debugCopyAll = 'Copy All';
  static const String debugCopiedToClipboard = 'Copied to clipboard';
  static const String debugCancel = 'Cancel';
  static const String debugCrash = 'Crash';
  static const String debugAppName = 'App Name';
  static const String debugVersion = 'Version';
  static const String debugBuildNumber = 'Build Number';
  static const String debugGitCommit = 'Git Commit';
  static const String debugFlutterVersion = 'Flutter Version';
  static const String debugDartVersion = 'Dart Version';
  static const String debugPlatform = 'Platform';
  static const String debugDesignSystem = 'Design System';
  static const String debugBuildDate = 'Build Date';
  static const String debugIsDebugBuild = 'Debug Build';

  // ─── Logs page ────────────────────────────────────────────────────────
  static const String logsTitle = 'Logs';
  static const String logsAll = 'All';
  static const String logsVerbose = 'Verbose';
  static const String logsDebug = 'Debug';
  static const String logsInfo = 'Info';
  static const String logsWarning = 'Warning';
  static const String logsError = 'Error';
  static const String logsClear = 'Clear';
  static const String logsClearConfirmTitle = 'Clear Logs';
  static const String logsClearConfirmBody =
      'Delete all log entries from memory?';
  static const String logsClearSuccess = 'Logs cleared';
  static const String logsDownload = 'Export';
  static const String logsDownloadSuccess = 'Logs saved to file';
  static const String logsDownloadError = 'Failed to save logs';
  static const String logsEmpty = 'No log entries';
  static const String logsCancel = 'Cancel';
  static const String logsConfirm = 'Clear';
  static const String logsCopied = 'Log entry copied';

  // ─── Developer settings ───────────────────────────────────────────────
  static const String settingsDeveloper = 'Developer';
  static const String settingsDebugMode = 'Debug Mode';
  static const String settingsDebugModeSubtitle =
      'Show Logs and Debug Info menu items';
  static const String settingsLogLevel = 'Log Level';
  static const String logLevelVerbose = 'Verbose';
  static const String logLevelDebug = 'Debug';
  static const String logLevelInfo = 'Info';
  static const String logLevelWarning = 'Warning';
  static const String logLevelError = 'Error';

  // ─── Licenses page ───────────────────────────────────────────────────
  static const String licensesTitle = 'Licenses';
  static const String licensesDetails =
      'Please refer to the package license file for details.';

  // ─── Splash screen ───────────────────────────────────────────────────
  static const String splashSubtitle = 'Point accumulation & spending';

  // ─── Common ──────────────────────────────────────────────────────────
  static const String commonRetry = 'Retry';
  static const String commonMenu = 'Menu';
  static const String commonNotifications = 'Notifications';
  static const String commonNotFound = '404 - Page not found';
  static const String commonPageNotFound = 'Page Not Found';
  static const String commonLoading = 'Loading...';
  static const String commonError = 'An error occurred';
  static const String commonEmpty = 'No data';
  static const String commonCancel = 'Cancel';
  static const String commonDelete = 'Delete';
  static const String commonAdd = 'Add';
  static const String commonSave = 'Save';

  // ─── Users ───────────────────────────────────────────────────────────
  static const String usersTitle = 'Users';
  static const String usersEmpty = 'No users yet. Tap + to add one.';
  static const String usersAdd = 'Add User';
  static const String usersAddTitle = 'Add User';
  static const String usersNameLabel = 'Name';
  static const String usersNameHint = 'Enter user name';
  static const String usersDeleteTitle = 'Delete User';
  static const String usersDeleteBody = 'Delete user';
  static const String pointBalance = 'Balance';

  // ─── Points ───────────────────────────────────────────────────────────
  static const String pointAdd = 'Add Points';
  static const String pointConsume = 'Consume Points';
  static const String pointHistoryEmpty = 'No point history yet.';
  static const String pointDateTime = 'Date & Time';
  static const String pointAmount = 'Points';
  static const String pointAmountHint = 'e.g. 100';
  static const String pointAmountError = 'Enter a positive number';
  static const String pointReason = 'Reason';
  static const String pointReasonHint = 'Why are points being added?';
  static const String pointReasonError = 'Reason is required';
  static const String pointApplication = 'Application';
  static const String pointApplicationHint = 'Where were the points used?';
  static const String pointApplicationError = 'Application is required';
  static const String pointTag = 'Tag (optional)';
  static const String pointTagHint = 'e.g. campaign, reward';
  static const String pointDeleteTitle = 'Delete Entry';
  static const String pointDeleteBody = 'Delete this point history entry?';
  static const String pointEditTitle = 'Edit Entry';

  // ─── Data export/import ───────────────────────────────────────────────
  static const String dataTitle = 'Data';
  static const String dataExportTitle = 'Export';
  static const String dataExportDesc =
      'Export all users and point history as a JSON file. '
      'On Android, it is saved to the public Downloads folder so it can be shared from other apps.';
  static const String dataExportButton = 'Export JSON';
  static const String dataExportSuccess = 'Export ready';
  static const String dataImportTitle = 'Import';
  static const String dataImportDesc =
      'Pick a previously exported JSON file to restore the data. '
      'This replaces existing users and history.';
  static const String dataImportButton = 'Pick JSON File';
  static const String dataImportSuccess = 'Import successful';
  static const String dataImportInvalid =
      'Selected file is not a valid export JSON.';
  static const String dataImportCountFormat = 'Imported %d users';
}
