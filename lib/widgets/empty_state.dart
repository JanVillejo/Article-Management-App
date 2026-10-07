import 'package:flutter/material.dart';

/// A small drawn illustration: a sheet of paper with a badge.
/// Built from plain widgets so it needs no image assets.
class EmptyIllustration extends StatelessWidget {
  const EmptyIllustration({super.key, required this.searching});

  /// Shows a magnifier badge instead of a pencil.
  final bool searching;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Widget bar(double width, {bool strong = false}) => Container(
          width: width,
          height: strong ? 10 : 7,
          decoration: BoxDecoration(
            color: strong
                ? scheme.primary.withValues(alpha: 0.55)
                : scheme.outlineVariant,
            borderRadius: BorderRadius.circular(4),
          ),
        );

    return SizedBox(
      width: 190,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 168,
            height: 168,
            decoration: BoxDecoration(
              color: scheme.secondaryContainer.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
          ),
          Positioned(
            top: 6,
            left: 14,
            child: Icon(Icons.auto_awesome_rounded,
                size: 22, color: scheme.tertiary),
          ),
          Positioned(
            top: 26,
            right: 8,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.35),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 14,
            left: 10,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: scheme.tertiary.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Transform.rotate(
            angle: -0.08,
            child: Container(
              width: 104,
              height: 128,
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: scheme.outlineVariant),
                boxShadow: [
                  BoxShadow(
                    color: scheme.shadow.withValues(alpha: 0.10),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  bar(54, strong: true),
                  const SizedBox(height: 14),
                  bar(72),
                  const SizedBox(height: 8),
                  bar(64),
                  const SizedBox(height: 8),
                  bar(70),
                  const SizedBox(height: 8),
                  bar(38),
                ],
              ),
            ),
          ),
          Positioned(
            right: 22,
            bottom: 12,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: scheme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: scheme.surface, width: 3),
              ),
              child: Icon(
                searching ? Icons.search_rounded : Icons.edit_rounded,
                color: scheme.onPrimary,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.searching,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.actionIcon,
    required this.onAction,
  });

  final bool searching;
  final String title;
  final String message;
  final String actionLabel;
  final IconData actionIcon;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 16, 32, 96),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            EmptyIllustration(searching: searching),
            const SizedBox(height: 24),
            Text(
              title,
              style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                message,
                style: text.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 28),
            searching
                ? FilledButton.tonalIcon(
                    onPressed: onAction,
                    icon: Icon(actionIcon),
                    label: Text(actionLabel),
                  )
                : FilledButton.icon(
                    onPressed: onAction,
                    icon: Icon(actionIcon),
                    label: Text(actionLabel),
                  ),
          ],
        ),
      ),
    );
  }
}
