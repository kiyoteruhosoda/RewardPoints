import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:rewardpoints/app/di/service_locator.dart';
import 'package:rewardpoints/presentation/pages/users_page.dart';
import 'package:rewardpoints/presentation/viewmodels/debug_settings_viewmodel.dart';
import 'package:rewardpoints/presentation/viewmodels/export_import_viewmodel.dart';
import 'package:rewardpoints/presentation/viewmodels/theme_viewmodel.dart';
import 'package:rewardpoints/presentation/widgets/ui/widgets.dart';
import 'package:rewardpoints/shared/l10n/app_strings.dart';
import 'package:rewardpoints/shared/logging/log_level.dart';
import 'package:rewardpoints/shared/theme/theme.dart';

/// Main screen with bottom navigation.
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  static const List<_TabItem> _tabs = [
    _TabItem(
      label: AppStrings.usersTitle,
      icon: Icons.people_outlined,
      selectedIcon: Icons.people,
    ),
    _TabItem(
      label: AppStrings.dataTitle,
      icon: Icons.import_export_outlined,
      selectedIcon: Icons.import_export,
    ),
    _TabItem(
      label: AppStrings.navSettings,
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Allow pop only when already on Home tab; otherwise switch to Home.
      canPop: _selectedIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          setState(() => _selectedIndex = 0);
        }
      },
      child: Scaffold(
      appBar: AppMainHeader(
        title: AppStrings.appName,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: AppStrings.commonMenu,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
            tooltip: AppStrings.commonNotifications,
          ),
        ],
      ),
      drawer: ListenableBuilder(
        listenable: sl<DebugSettingsViewModel>(),
        builder: (context, _) {
          final debugEnabled = sl<DebugSettingsViewModel>().debugEnabled;
          return AppDrawer(
            appName: AppStrings.appName,
            headerSubtitle: AppStrings.drawerSubtitle,
            items: [
              AppDrawerItem(
                label: AppStrings.usersTitle,
                icon: Icons.people_outlined,
                isSelected: _selectedIndex == 0,
                onTap: () {
                  setState(() => _selectedIndex = 0);
                  Navigator.of(context).pop();
                },
              ),
              AppDrawerItem(
                label: AppStrings.dataTitle,
                icon: Icons.import_export_outlined,
                isSelected: _selectedIndex == 1,
                onTap: () {
                  setState(() => _selectedIndex = 1);
                  Navigator.of(context).pop();
                },
              ),
              AppDrawerItem(
                label: AppStrings.navSettings,
                icon: Icons.settings_outlined,
                isSelected: _selectedIndex == 2,
                onTap: () {
                  setState(() => _selectedIndex = 2);
                  Navigator.of(context).pop();
                },
              ),
              const AppDrawerItem.divider(),
            ],
            bottomItems: [
              AppDrawerItem(
                label: AppStrings.drawerAbout,
                icon: Icons.info_outline,
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed('/about');
                },
              ),
              AppDrawerItem(
                label: AppStrings.drawerLicenses,
                icon: Icons.description_outlined,
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed('/licenses');
                },
              ),
              if (debugEnabled) ...[
                AppDrawerItem(
                  label: AppStrings.drawerLogs,
                  icon: Icons.list_alt_outlined,
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamed('/logs');
                  },
                ),
                AppDrawerItem(
                  label: AppStrings.drawerDebug,
                  icon: Icons.bug_report_outlined,
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamed('/debug');
                  },
                ),
              ],
            ],
          );
        },
      ),
      body: _buildTabContent(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: _tabs
            .map(
              (tab) => NavigationDestination(
                icon: Icon(tab.icon),
                selectedIcon: Icon(tab.selectedIcon),
                label: tab.label,
              ),
            )
            .toList(),
      ),
      ),
    );
  }

  Widget _buildTabContent() {
    return switch (_selectedIndex) {
      0 => const UsersPage(),
      1 => const _DataContent(),
      2 => const _SettingsContent(),
      _ => const UsersPage(),
    };
  }
}

// ─── Tab Content ─────────────────────────────────────────────────────────────

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pageMargin),
      children: [
        AppSectionHeader(
          title: AppStrings.homeWelcomeTitle,
          subtitle: AppStrings.homeWelcomeSubtitle,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.homeCardTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                AppStrings.homeCardBody,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppSectionHeader(title: AppStrings.homeComponentsTitle),
        const SizedBox(height: AppSpacing.lg),
        AppPrimaryButton(
          label: AppStrings.homePrimaryButton,
          onPressed: () {},
          width: double.infinity,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppSecondaryButton(
          label: AppStrings.homeSecondaryButton,
          onPressed: () {},
          width: double.infinity,
        ),
        const SizedBox(height: AppSpacing.lg),
        const AppTextField(
          label: AppStrings.homeTextFieldLabel,
          hint: AppStrings.homeTextFieldHint,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppListCard(
          title: AppStrings.homeListCardTitle,
          subtitle: AppStrings.homeListCardSubtitle,
          leading: const Icon(Icons.article_outlined),
          onTap: () {},
        ),
        const SizedBox(height: AppSpacing.sm),
        AppListCard(
          title: AppStrings.homeListCardItem2,
          subtitle: AppStrings.homeListCardSubtitle,
          leading: const Icon(Icons.article_outlined),
          onTap: () {},
        ),
      ],
    );
  }
}

class _SearchContent extends StatelessWidget {
  const _SearchContent();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.pageMargin),
      child: Column(
        children: [
          AppTextField(
            label: AppStrings.searchFieldLabel,
            hint: AppStrings.searchFieldHint,
            prefixIcon: Icon(Icons.search),
          ),
          SizedBox(height: AppSpacing.xxxl),
          AppEmptyView(
            message: AppStrings.searchEmptyMessage,
            icon: Icons.search,
          ),
        ],
      ),
    );
  }
}

class _DataContent extends StatefulWidget {
  const _DataContent();

  @override
  State<_DataContent> createState() => _DataContentState();
}

class _DataContentState extends State<_DataContent> {
  late final ExportImportViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<ExportImportViewModel>();
    _viewModel.addListener(_onChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => setState(() {});

  Future<void> _doExport() async {
    await _viewModel.exportData();
    if (!mounted) return;
    if (_viewModel.state == ExportImportState.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${AppStrings.dataExportSuccess}: ${_viewModel.lastMessage ?? ''}'),
        ),
      );
      _viewModel.reset();
    } else if (_viewModel.state == ExportImportState.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.error?.message ?? AppStrings.commonError),
        ),
      );
      _viewModel.reset();
    }
  }

  Future<void> _doImportPick() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final picked = result.files.single;
    final jsonContent = await _readPicked(picked);
    if (jsonContent == null) return;
    await _viewModel.importFromJson(jsonContent);
    if (!mounted) return;
    if (_viewModel.state == ExportImportState.success) {
      final count = _viewModel.lastMessage ?? '0';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.dataImportCountFormat.replaceFirst('%d', count),
          ),
        ),
      );
      _viewModel.reset();
    } else if (_viewModel.state == ExportImportState.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.dataImportInvalid),
        ),
      );
      _viewModel.reset();
    }
  }

  Future<String?> _readPicked(PlatformFile file) async {
    if (file.bytes != null) {
      return utf8.decode(file.bytes!);
    }
    final path = file.path;
    if (path != null) {
      return File(path).readAsString();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pageMargin),
      children: [
        AppSectionHeader(title: AppStrings.dataExportTitle),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.dataExportDesc,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppPrimaryButton(
                label: _viewModel.state == ExportImportState.loading
                    ? AppStrings.commonLoading
                    : AppStrings.dataExportButton,
                onPressed: _viewModel.state == ExportImportState.loading
                    ? null
                    : _doExport,
                width: double.infinity,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        AppSectionHeader(title: AppStrings.dataImportTitle),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.dataImportDesc,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppSecondaryButton(
                label: _viewModel.state == ExportImportState.loading
                    ? AppStrings.commonLoading
                    : AppStrings.dataImportButton,
                onPressed: _viewModel.state == ExportImportState.loading
                    ? null
                    : _doImportPick,
                width: double.infinity,
              ),
            ],
          ),
        ),
        if (_viewModel.state == ExportImportState.error)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.lg),
            child: Text(
              _viewModel.error?.message ?? AppStrings.commonError,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    );
  }
}

class _SettingsContent extends StatelessWidget {
  const _SettingsContent();

  @override
  Widget build(BuildContext context) {
    final themeViewModel = sl<ThemeViewModel>();
    final debugViewModel = sl<DebugSettingsViewModel>();
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pageMargin),
      children: [
        AppSectionHeader(title: AppStrings.settingsTitle),
        const SizedBox(height: AppSpacing.lg),
        // ── Theme switcher ──────────────────────────────────────────
        AppSectionHeader(title: AppStrings.settingsTheme),
        const SizedBox(height: AppSpacing.sm),
        ListenableBuilder(
          listenable: themeViewModel,
          builder: (context, _) => AppCard(
            child: Column(
              children: [
                _ThemeOptionTile(
                  label: AppStrings.settingsThemeLight,
                  icon: Icons.light_mode_outlined,
                  value: ThemeMode.light,
                  groupValue: themeViewModel.themeMode,
                  onChanged: themeViewModel.setThemeMode,
                ),
                const Divider(height: 1),
                _ThemeOptionTile(
                  label: AppStrings.settingsThemeDark,
                  icon: Icons.dark_mode_outlined,
                  value: ThemeMode.dark,
                  groupValue: themeViewModel.themeMode,
                  onChanged: themeViewModel.setThemeMode,
                ),
                const Divider(height: 1),
                _ThemeOptionTile(
                  label: AppStrings.settingsThemeSystem,
                  icon: Icons.brightness_auto_outlined,
                  value: ThemeMode.system,
                  groupValue: themeViewModel.themeMode,
                  onChanged: themeViewModel.setThemeMode,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        // ── Developer section ────────────────────────────────────────
        AppSectionHeader(title: AppStrings.settingsDeveloper),
        const SizedBox(height: AppSpacing.sm),
        ListenableBuilder(
          listenable: debugViewModel,
          builder: (context, _) => AppCard(
            child: Column(
              children: [
                SwitchListTile(
                  value: debugViewModel.debugEnabled,
                  onChanged: debugViewModel.setDebugEnabled,
                  secondary: Icon(
                    Icons.bug_report_outlined,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  title: Text(
                    AppStrings.settingsDebugMode,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  subtitle: Text(
                    AppStrings.settingsDebugModeSubtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.componentPadding,
                    vertical: AppSpacing.xs,
                  ),
                ),
                if (debugViewModel.debugEnabled) ...[
                  const Divider(height: 1),
                  _LogLevelTile(
                    currentLevel: debugViewModel.logLevel,
                    onChanged: debugViewModel.setLogLevel,
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppListCard(
          title: AppStrings.settingsAbout,
          leading: const Icon(Icons.info_outline),
          onTap: () => Navigator.of(context).pushNamed('/about'),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppListCard(
          title: AppStrings.settingsLicenses,
          leading: const Icon(Icons.description_outlined),
          onTap: () => Navigator.of(context).pushNamed('/licenses'),
        ),
        ListenableBuilder(
          listenable: debugViewModel,
          builder: (context, _) => debugViewModel.debugEnabled
              ? Column(
                  children: [
                    const SizedBox(height: AppSpacing.sm),
                    AppListCard(
                      title: AppStrings.settingsLogs,
                      leading: const Icon(Icons.list_alt_outlined),
                      onTap: () => Navigator.of(context).pushNamed('/logs'),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppListCard(
                      title: AppStrings.settingsDebug,
                      leading: const Icon(Icons.bug_report_outlined),
                      onTap: () => Navigator.of(context).pushNamed('/debug'),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _ThemeOptionTile extends StatelessWidget {
  const _ThemeOptionTile({
    required this.label,
    required this.icon,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final ThemeMode value;
  final ThemeMode groupValue;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(
        icon,
        color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
      ),
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color:
                  selected ? colorScheme.primary : colorScheme.onSurface,
              fontWeight:
                  selected ? FontWeight.w700 : FontWeight.w400,
            ),
      ),
      trailing: selected
          ? Icon(Icons.check_circle, color: colorScheme.primary)
          : Icon(Icons.radio_button_unchecked,
              color: colorScheme.onSurfaceVariant),
      onTap: () => onChanged(value),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.componentPadding,
        vertical: AppSpacing.xs,
      ),
    );
  }
}

class _LogLevelTile extends StatelessWidget {
  const _LogLevelTile({
    required this.currentLevel,
    required this.onChanged,
  });

  final LogLevel currentLevel;
  final ValueChanged<LogLevel> onChanged;

  static const List<(LogLevel, String)> _levels = [
    (LogLevel.verbose, AppStrings.logLevelVerbose),
    (LogLevel.debug, AppStrings.logLevelDebug),
    (LogLevel.info, AppStrings.logLevelInfo),
    (LogLevel.warning, AppStrings.logLevelWarning),
    (LogLevel.error, AppStrings.logLevelError),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(
        Icons.tune_outlined,
        color: colorScheme.onSurfaceVariant,
      ),
      title: Text(
        AppStrings.settingsLogLevel,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      trailing: DropdownButton<LogLevel>(
        value: currentLevel,
        underline: const SizedBox.shrink(),
        onChanged: (level) {
          if (level != null) onChanged(level);
        },
        items: _levels
            .map(
              (entry) => DropdownMenuItem(
                value: entry.$1,
                child: Text(entry.$2),
              ),
            )
            .toList(),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.componentPadding,
        vertical: AppSpacing.xs,
      ),
    );
  }
}

class _TabItem {
  const _TabItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
