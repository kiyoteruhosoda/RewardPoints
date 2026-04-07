import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterbase/app/di/service_locator.dart';
import 'package:flutterbase/presentation/viewmodels/debug_viewmodel.dart';
import 'package:flutterbase/presentation/widgets/ui/widgets.dart';
import 'package:flutterbase/shared/l10n/app_strings.dart';
import 'package:flutterbase/shared/theme/theme.dart';

/// Debug information page — shows build metadata and diagnostic actions.
class DebugPage extends StatefulWidget {
  const DebugPage({super.key});

  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  late final DebugViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<DebugViewModel>();
    _viewModel.addListener(_onViewModelChange);
    _viewModel.loadAppInfo();
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChange);
    super.dispose();
  }

  void _onViewModelChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppMainHeader(
        title: AppStrings.debugTitle,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: _copyAllToClipboard,
            tooltip: AppStrings.debugCopyAll,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pageMargin),
        children: [
          // Warning banner
          Container(
            padding: const EdgeInsets.all(AppSpacing.componentPadding),
            decoration: BoxDecoration(
              color: AppColors.statusWarningBg,
              borderRadius: AppRadius.lgBorder,
              border: Border.all(color: AppColors.statusWarning),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: AppColors.statusWarning),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    AppStrings.debugWarning,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.statusWarning,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // App info card
          AppSectionHeader(title: AppStrings.debugAppInfoSection),
          const SizedBox(height: AppSpacing.sm),
          switch (_viewModel.state) {
            DebugState.loading => const AppLoadingView(),
            DebugState.error => AppErrorView(
                message: _viewModel.appError?.message ?? AppStrings.commonError,
                onRetry: _viewModel.loadAppInfo,
              ),
            DebugState.loaded => _buildInfoCard(context),
          },
          const SizedBox(height: AppSpacing.lg),

          // Theme info card
          AppSectionHeader(title: AppStrings.debugThemeSection),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            child: Column(
              children: [
                _DebugInfoRow(
                  label: AppStrings.debugThemeMode,
                  value: Theme.of(context).brightness == Brightness.dark
                      ? AppStrings.debugThemeModeDark
                      : AppStrings.debugThemeModeLight,
                ),
                const Divider(height: AppSpacing.xl),
                _DebugInfoRow(
                  label: AppStrings.debugPrimaryColor,
                  value: colorScheme.primary.toHexString(),
                  valueWidget: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: AppSpacing.iconSm,
                        height: AppSpacing.iconSm,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: AppRadius.smBorder,
                          border: Border.all(color: colorScheme.outline),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        colorScheme.primary.toHexString(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const Divider(height: AppSpacing.xl),
                _DebugInfoRow(
                  label: AppStrings.debugSurfaceColor,
                  value: colorScheme.surface.toHexString(),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Actions card
          AppSectionHeader(title: AppStrings.debugActionsSection),
          const SizedBox(height: AppSpacing.sm),
          AppListCard(
            title: AppStrings.debugClearLogs,
            leading: const Icon(Icons.clear_all),
            onTap: () {
              _viewModel.clearLogs();
              _showSnackBar(AppStrings.debugClearLogsSuccess);
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          AppListCard(
            title: AppStrings.debugClearCache,
            leading: const Icon(Icons.cleaning_services_outlined),
            onTap: () => _showSnackBar(AppStrings.debugClearCacheSuccess),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppListCard(
            title: AppStrings.debugTestCrash,
            leading: Icon(Icons.warning, color: AppColors.statusError),
            onTap: _showCrashConfirmDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final info = _viewModel.appInfo!;
    final entries = <(String, String)>[
      (AppStrings.debugAppName, AppStrings.appName),
      (AppStrings.debugVersion, info.version),
      (AppStrings.debugBuildNumber, info.buildNumber),
      (AppStrings.debugGitCommit, info.gitCommitFull),
      (AppStrings.debugFlutterVersion, info.flutterVersion),
      (AppStrings.debugDartVersion, info.dartVersion),
      (AppStrings.debugPlatform, AppStrings.aboutPlatformValue),
      (AppStrings.debugDesignSystem, AppStrings.aboutDesignSystemValue),
      (AppStrings.debugBuildDate, info.buildDate),
      (AppStrings.debugIsDebugBuild, info.isDebug.toString()),
    ];
    return AppCard(
      child: Column(
        children: List.generate(entries.length, (i) {
          return Column(
            children: [
              if (i > 0) const Divider(height: AppSpacing.xl),
              _DebugInfoRow(label: entries[i].$1, value: entries[i].$2),
            ],
          );
        }),
      ),
    );
  }

  void _copyAllToClipboard() {
    if (_viewModel.appInfo == null) return;
    final info = _viewModel.appInfo!;
    final buffer = StringBuffer()
      ..writeln('${AppStrings.debugAppName}: ${AppStrings.appName}')
      ..writeln('${AppStrings.debugVersion}: ${info.version}')
      ..writeln('${AppStrings.debugBuildNumber}: ${info.buildNumber}')
      ..writeln('${AppStrings.debugGitCommit}: ${info.gitCommitFull}')
      ..writeln('${AppStrings.debugFlutterVersion}: ${info.flutterVersion}')
      ..writeln('${AppStrings.debugDartVersion}: ${info.dartVersion}')
      ..writeln('${AppStrings.debugBuildDate}: ${info.buildDate}')
      ..writeln('${AppStrings.debugIsDebugBuild}: ${info.isDebug}');
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    _showSnackBar(AppStrings.debugCopiedToClipboard);
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showCrashConfirmDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.debugTestCrashTitle),
        content: const Text(AppStrings.debugTestCrashBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.debugCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(AppStrings.debugCrash),
          ),
        ],
      ),
    );
    if (confirmed == true) throw Exception('Test crash');
  }
}

class _DebugInfoRow extends StatelessWidget {
  const _DebugInfoRow({
    required this.label,
    required this.value,
    this.valueWidget,
  });

  final String label;
  final String value;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: valueWidget ??
              SelectableText(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
        ),
      ],
    );
  }
}

extension ColorExtension on Color {
  /// Returns the color as an uppercase hex string (e.g. "#1A2B3C").
  String toHexString() {
    // ignore: deprecated_member_use
    final v = value; // ARGB32 int — works across all Flutter versions
    final r = ((v >> 16) & 0xFF).toRadixString(16).padLeft(2, '0');
    final g = ((v >> 8) & 0xFF).toRadixString(16).padLeft(2, '0');
    final b = (v & 0xFF).toRadixString(16).padLeft(2, '0');
    return '#${r.toUpperCase()}${g.toUpperCase()}${b.toUpperCase()}';
  }
}
