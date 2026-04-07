import 'package:flutter/material.dart';
import 'package:flutterbase/shared/theme/theme.dart';

/// DADS-compliant card container.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.semanticLabel,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.lgBorder,
          child: Padding(
            padding:
                padding ?? const EdgeInsets.all(AppSpacing.componentPadding),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// List-style card item with leading icon, title, subtitle, and optional action.
class AppListCard extends StatelessWidget {
  const AppListCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: ListTile(
        title: Text(title, style: Theme.of(context).textTheme.titleSmall),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall,
              )
            : null,
        leading: leading,
        trailing: trailing ??
            (onTap != null ? const Icon(Icons.chevron_right) : null),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.componentPadding,
          vertical: AppSpacing.sm,
        ),
      ),
    );
  }
}
