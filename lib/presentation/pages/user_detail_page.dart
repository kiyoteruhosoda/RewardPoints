import 'package:flutter/material.dart';
import 'package:flutterbase/app/di/service_locator.dart';
import 'package:flutterbase/application/dto/point_entry_dto.dart';
import 'package:flutterbase/presentation/viewmodels/user_detail_viewmodel.dart';
import 'package:flutterbase/presentation/widgets/ui/widgets.dart';
import 'package:flutterbase/shared/l10n/app_strings.dart';
import 'package:flutterbase/shared/theme/theme.dart';

class UserDetailPage extends StatefulWidget {
  const UserDetailPage({
    super.key,
    required this.userId,
    required this.userName,
  });
  final int userId;
  final String userName;

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  late final UserDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = sl<UserDetailViewModel>();
    _viewModel.addListener(_onChanged);
    _viewModel.load(widget.userId);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppMainHeader(title: widget.userName),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            color: colorScheme.primaryContainer,
            child: Column(
              children: [
                Text(
                  AppStrings.pointBalance,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                      ),
                ),
                Text(
                  '${_viewModel.balance} pts',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: AppPrimaryButton(
                    label: AppStrings.pointAdd,
                    onPressed: () => Navigator.of(context)
                        .pushNamed('/add-points', arguments: widget.userId)
                        .then((_) => _viewModel.load(widget.userId)),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppSecondaryButton(
                    label: AppStrings.pointConsume,
                    onPressed: () => Navigator.of(context)
                        .pushNamed('/consume-points', arguments: widget.userId)
                        .then((_) => _viewModel.load(widget.userId)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: switch (_viewModel.state) {
              UserDetailState.loading => const AppLoadingView(),
              UserDetailState.error => AppErrorView(
                  message: _viewModel.error?.message ?? AppStrings.commonError,
                  onRetry: () => _viewModel.load(widget.userId),
                ),
              UserDetailState.empty => const AppEmptyView(
                  message: AppStrings.pointHistoryEmpty,
                  icon: Icons.history,
                ),
              UserDetailState.loaded => _buildHistory(context),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHistory(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageMargin),
      itemCount: _viewModel.entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final entry = _viewModel.entries[index];
        return Dismissible(
          key: ValueKey(entry.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: AppSpacing.lg),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: AppRadius.smBorder,
            ),
            child: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
          confirmDismiss: (_) async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text(AppStrings.pointDeleteTitle),
                content: const Text(AppStrings.pointDeleteBody),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text(AppStrings.commonCancel),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: Text(
                      AppStrings.commonDelete,
                      style: TextStyle(
                          color: Theme.of(ctx).colorScheme.error),
                    ),
                  ),
                ],
              ),
            );
            return confirmed == true;
          },
          onDismissed: (_) => _viewModel.deleteEntry(entry.id),
          child: _EntryCard(entry: entry),
        );
      },
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry});
  final PointEntryDto entry;

  @override
  Widget build(BuildContext context) {
    final isAddition = entry.type == PointEntryTypeDto.addition;
    final colorScheme = Theme.of(context).colorScheme;
    final pointColor =
        isAddition ? Colors.green.shade700 : colorScheme.error;
    final pointPrefix = isAddition ? '+' : '-';

    String subtitle;
    if (isAddition) {
      final reason = entry.reason ?? '';
      subtitle = '${AppStrings.pointReason}: $reason';
      if (entry.tag != null) {
        subtitle += ' · ${AppStrings.pointTag}: ${entry.tag}';
      }
    } else {
      subtitle = '${AppStrings.pointApplication}: ${entry.application ?? ''}';
      if (entry.tag != null) {
        subtitle += ' · ${AppStrings.pointTag}: ${entry.tag}';
      }
    }

    return AppCard(
      child: Row(
        children: [
          Icon(
            isAddition
                ? Icons.add_circle_outline
                : Icons.remove_circle_outline,
            color: pointColor,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  _formatDate(entry.dateTime),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Text(
            '$pointPrefix${entry.points} pts',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: pointColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
