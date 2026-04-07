import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterbase/app/di/service_locator.dart';
import 'package:flutterbase/presentation/widgets/ui/widgets.dart';
import 'package:flutterbase/shared/l10n/app_strings.dart';
import 'package:flutterbase/shared/logging/app_logger.dart';
import 'package:flutterbase/shared/theme/theme.dart';

/// Displays the in-memory log buffer with level filtering and export.
class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  LogLevel? _filter; // null = all
  late final AppLogger _logger = sl<AppLogger>();

  @override
  Widget build(BuildContext context) {
    final entries = _logger.entriesForLevel(_filter).reversed.toList();

    return Scaffold(
      appBar: AppMainHeader(
        title: AppStrings.logsTitle,
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            tooltip: AppStrings.logsDownload,
            onPressed: _exportLogs,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: AppStrings.logsClear,
            onPressed: _confirmClear,
          ),
        ],
      ),
      body: Column(
        children: [
          _FilterBar(
            selected: _filter,
            onChanged: (level) => setState(() => _filter = level),
          ),
          const Divider(height: 1),
          Expanded(
            child: entries.isEmpty
                ? const AppEmptyView(
                    message: AppStrings.logsEmpty,
                    icon: Icons.list_alt_outlined,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    itemCount: entries.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) =>
                        _LogEntryTile(entry: entries[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportLogs() async {
    final path = await _logger.exportLogs();
    if (!mounted) return;
    final msg =
        path != null ? AppStrings.logsDownloadSuccess : AppStrings.logsDownloadError;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _confirmClear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.logsClearConfirmTitle),
        content: const Text(AppStrings.logsClearConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(AppStrings.logsCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(AppStrings.logsConfirm),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      _logger.clearBuffer();
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.logsClearSuccess)),
        );
      }
    }
  }
}

// ─── Filter bar ──────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onChanged});

  final LogLevel? selected;
  final ValueChanged<LogLevel?> onChanged;

  static const _options = <(String, LogLevel?)>[
    (AppStrings.logsAll, null),
    (AppStrings.logsVerbose, LogLevel.verbose),
    (AppStrings.logsDebug, LogLevel.debug),
    (AppStrings.logsInfo, LogLevel.info),
    (AppStrings.logsWarning, LogLevel.warning),
    (AppStrings.logsError, LogLevel.error),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageMargin,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: _options
            .map(
              (opt) => Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: _FilterChip(
                  label: opt.$1,
                  selected: selected == opt.$2,
                  onSelected: () => onChanged(opt.$2),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: colorScheme.primaryContainer,
      checkmarkColor: colorScheme.primary,
      labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
          ),
      side: BorderSide(
        color: selected ? colorScheme.primary : colorScheme.outline,
      ),
    );
  }
}

// ─── Log entry tile ───────────────────────────────────────────────────────────

class _LogEntryTile extends StatelessWidget {
  const _LogEntryTile({required this.entry});

  final LogEntry entry;

  Color _levelColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return switch (entry.level) {
      LogLevel.verbose => cs.onSurfaceVariant,
      LogLevel.debug => cs.primary,
      LogLevel.info => AppColors.statusInfo,
      LogLevel.warning => AppColors.statusWarning,
      LogLevel.error => cs.error,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _levelColor(context);
    final ts = _formatTimestamp(entry.timestamp);

    return InkWell(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: entry.toLogLine()));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.logsCopied)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pageMargin,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Level badge
            Container(
              width: AppSpacing.levelBadgeSize,
              height: AppSpacing.levelBadgeSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: AppRadius.smBorder,
              ),
              child: Text(
                entry.levelLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.message,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (entry.error != null)
                    Text(
                      '${entry.error}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              ts,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}
