import 'package:flutter/material.dart';
import 'package:flutterbase/app/di/service_locator.dart';
import 'package:flutterbase/presentation/viewmodels/about_viewmodel.dart';
import 'package:flutterbase/presentation/widgets/ui/widgets.dart';
import 'package:flutterbase/shared/l10n/app_strings.dart';
import 'package:flutterbase/shared/theme/theme.dart';

/// About / version information page.
class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  late final AboutViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<AboutViewModel>();
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
      appBar: AppMainHeader(title: AppStrings.aboutTitle),
      body: switch (_viewModel.state) {
        AboutState.loading => const AppLoadingView(),
        AboutState.error => AppErrorView(
            message: _viewModel.appError?.message ?? AppStrings.commonError,
            onRetry: _viewModel.loadAppInfo,
          ),
        AboutState.loaded => _buildContent(context, colorScheme),
      },
    );
  }

  Widget _buildContent(BuildContext context, ColorScheme colorScheme) {
    final info = _viewModel.appInfo!;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pageMargin),
      children: [
        const SizedBox(height: AppSpacing.xl),
        Center(
          child: Container(
            width: AppSpacing.aboutIconContainer,
            height: AppSpacing.aboutIconContainer,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: AppRadius.xlBorder,
            ),
            child: Icon(Icons.web_asset, size: AppSpacing.aboutIconSize, color: colorScheme.primary),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Center(
          child: Text(
            AppStrings.appName,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Center(
          child: Text(
            AppStrings.appDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        AppCard(
          child: Column(
            children: [
              _InfoRow(label: AppStrings.aboutVersion, value: info.version),
              const Divider(height: AppSpacing.xl),
              _InfoRow(label: AppStrings.aboutBuildNumber, value: info.buildNumber),
              const Divider(height: AppSpacing.xl),
              _InfoRow(label: AppStrings.aboutGitCommit, value: info.gitCommit),
              const Divider(height: AppSpacing.xl),
              _InfoRow(label: AppStrings.aboutFlutterVersion, value: info.flutterVersion),
              const Divider(height: AppSpacing.xl),
              _InfoRow(label: AppStrings.aboutDartVersion, value: info.dartVersion),
              const Divider(height: AppSpacing.xl),
              _InfoRow(
                label: AppStrings.aboutDesignSystem,
                value: AppStrings.aboutDesignSystemValue,
              ),
              const Divider(height: AppSpacing.xl),
              _InfoRow(
                label: AppStrings.aboutPlatform,
                value: AppStrings.aboutPlatformValue,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.aboutDesignSystemSectionTitle,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                AppStrings.aboutDesignSystemBody,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.open_in_new, size: AppSpacing.iconSm),
                label: const Text(AppStrings.aboutDesignSystemLink),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        Text(value, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
