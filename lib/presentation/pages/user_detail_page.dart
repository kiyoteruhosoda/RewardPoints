import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterbase/app/di/service_locator.dart';
import 'package:flutterbase/application/dto/point_entry_dto.dart';
import 'package:flutterbase/application/dto/update_point_entry_dto.dart';
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

  Future<void> _showEditDialog(PointEntryDto entry) async {
    final dto = await showDialog<UpdatePointEntryDto>(
      context: context,
      builder: (ctx) => _EditEntryDialog(entry: entry),
    );
    if (dto != null && mounted) {
      await _viewModel.updateEntry(dto);
    }
  }

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
          child: InkWell(
            onTap: () => _showEditDialog(entry),
            borderRadius: AppRadius.smBorder,
            child: _EntryCard(entry: entry),
          ),
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
          const SizedBox(width: AppSpacing.xs),
          Icon(
            Icons.edit_outlined,
            size: 16,
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

class _EditEntryDialog extends StatefulWidget {
  const _EditEntryDialog({required this.entry});
  final PointEntryDto entry;

  @override
  State<_EditEntryDialog> createState() => _EditEntryDialogState();
}

class _EditEntryDialogState extends State<_EditEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _mainController = TextEditingController();
  final _pointsController = TextEditingController();
  final _tagController = TextEditingController();
  late DateTime _selectedDate;

  bool get _isAddition => widget.entry.type == PointEntryTypeDto.addition;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.entry.dateTime;
    _mainController.text =
        (_isAddition ? widget.entry.reason : widget.entry.application) ?? '';
    _pointsController.text = widget.entry.points.toString();
    _tagController.text = widget.entry.tag ?? '';
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pointsController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
    );
    if (time == null) return;
    setState(() {
      _selectedDate = DateTime(
          date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      UpdatePointEntryDto(
        id: widget.entry.id,
        dateTime: _selectedDate,
        points: int.parse(_pointsController.text),
        reason: _isAddition ? _mainController.text.trim() : null,
        application: _isAddition ? null : _mainController.text.trim(),
        tag: _tagController.text.trim().isEmpty
            ? null
            : _tagController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.pointEditTitle),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppCard(
                child: ListTile(
                  dense: true,
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: const Text(AppStrings.pointDateTime),
                  subtitle: Text(_formatDate(_selectedDate)),
                  onTap: _pickDate,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _mainController,
                decoration: InputDecoration(
                  labelText: _isAddition
                      ? AppStrings.pointReason
                      : AppStrings.pointApplication,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? (_isAddition
                        ? AppStrings.pointReasonError
                        : AppStrings.pointApplicationError)
                    : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _pointsController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: AppStrings.pointAmount,
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null ||
                            v.isEmpty ||
                            int.tryParse(v) == null ||
                            int.parse(v) <= 0)
                        ? AppStrings.pointAmountError
                        : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _tagController,
                decoration: const InputDecoration(
                  labelText: AppStrings.pointTag,
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AppStrings.commonCancel),
        ),
        TextButton(
          onPressed: _save,
          child: const Text(AppStrings.commonSave),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
