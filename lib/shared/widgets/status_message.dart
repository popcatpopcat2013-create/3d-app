import 'package:flutter/material.dart';

/// A centered icon, title, short message and optional buttons.
/// Used for "nothing here", "all done", errors, and the permission screen.
class StatusMessage extends StatelessWidget {
  const StatusMessage({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.iconColor,
    this.actions = const [],
  });

  final IconData icon;
  final String title;
  final String? message;
  final Color? iconColor;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final message = this.message;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72, color: iconColor ?? theme.colorScheme.primary),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            if (message != null) ...[
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
            if (actions.isNotEmpty) const SizedBox(height: 28),
            for (final action in actions)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: action,
              ),
          ],
        ),
      ),
    );
  }
}
