import 'package:flutter/material.dart';
import 'package:flutterbase/shared/l10n/app_strings.dart';
import 'package:flutterbase/shared/theme/theme.dart';

/// DADS-compliant side drawer menu.
class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.appName,
    this.headerSubtitle,
    required this.items,
    this.bottomItems,
    this.onClose,
  });

  final String appName;
  final String? headerSubtitle;
  final List<AppDrawerItem> items;
  final List<AppDrawerItem>? bottomItems;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            _DrawerHeader(
              appName: appName,
              subtitle: headerSubtitle,
              colorScheme: colorScheme,
              onClose: onClose ?? () => Navigator.of(context).pop(),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: AppSpacing.sm),
                  ...items.map((item) => _DrawerItemTile(item: item)),
                ],
              ),
            ),
            if (bottomItems != null && bottomItems!.isNotEmpty) ...[
              const Divider(height: 1),
              ...bottomItems!.map((item) => _DrawerItemTile(item: item)),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({
    required this.appName,
    required this.colorScheme,
    required this.onClose,
    this.subtitle,
  });

  final String appName;
  final String? subtitle;
  final ColorScheme colorScheme;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageMargin,
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClose,
            tooltip: AppStrings.drawerClose,
          ),
        ],
      ),
    );
  }
}

class _DrawerItemTile extends StatelessWidget {
  const _DrawerItemTile({required this.item});
  final AppDrawerItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (item.isDivider) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Divider(height: 1),
      );
    }

    return ListTile(
      leading: item.icon != null
          ? Icon(
              item.icon,
              color: item.isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            )
          : null,
      title: Text(
        item.label,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: item.isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurface,
              fontWeight:
                  item.isSelected ? FontWeight.w700 : FontWeight.w400,
            ),
      ),
      selected: item.isSelected,
      selectedTileColor: colorScheme.primaryContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.smBorder,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageMargin,
        vertical: AppSpacing.xs,
      ),
      minVerticalPadding: AppSpacing.sm,
      onTap: item.onTap,
    );
  }
}

class AppDrawerItem {
  const AppDrawerItem({
    required this.label,
    this.icon,
    this.onTap,
    this.isSelected = false,
    this.isDivider = false,
  });

  /// Factory for separator items.
  const AppDrawerItem.divider()
      : label = '',
        icon = null,
        onTap = null,
        isSelected = false,
        isDivider = true;

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isDivider;
}
