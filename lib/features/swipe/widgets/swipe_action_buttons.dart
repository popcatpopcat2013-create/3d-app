import 'package:flutter/material.dart';
import 'package:photo_swipe/core/strings.dart';
import 'package:photo_swipe/core/theme.dart';

/// The two big round buttons under the deck: trash (left) and keep (right).
/// This is also where the undo button will go later.
class SwipeActionButtons extends StatelessWidget {
  const SwipeActionButtons({
    super.key,
    required this.onTrash,
    required this.onKeep,
  });

  final VoidCallback onTrash;
  final VoidCallback onKeep;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _RoundButton(
          icon: Icons.close_rounded,
          label: AppStrings.trashLabel,
          color: AppColors.trash,
          onPressed: onTrash,
        ),
        _RoundButton(
          icon: Icons.favorite_rounded,
          label: AppStrings.keepLabel,
          color: AppColors.keep,
          onPressed: onKeep,
        ),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 72,
          height: 72,
          child: FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              padding: EdgeInsets.zero,
            ),
            child: Icon(icon, size: 36),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: Theme.of(context).textTheme.labelLarge),
      ],
    );
  }
}
