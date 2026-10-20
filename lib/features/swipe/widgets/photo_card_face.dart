import 'package:flutter/material.dart';
import 'package:photo_swipe/core/strings.dart';
import 'package:photo_swipe/core/theme.dart';
import 'package:photo_swipe/models/photo_item.dart';
import 'package:photo_swipe/shared/widgets/photo_thumbnail.dart';

/// What a swipe card looks like: the photo, plus a green "keep" or red
/// "trash" tint that grows as the card is dragged to the right or left.
class PhotoCardFace extends StatelessWidget {
  const PhotoCardFace({
    super.key,
    required this.photo,
    this.keepAmount = 0,
  });

  final PhotoItem photo;

  /// From -1 (dragged fully left = trash) to 1 (dragged fully right = keep).
  final double keepAmount;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isKeep = keepAmount > 0;
    final strength = keepAmount.abs().clamp(0.0, 1.0);
    final tint = isKeep ? AppColors.keep : AppColors.trash;

    return Material(
      elevation: 6,
      color: colors.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PhotoThumbnail(
            photoId: photo.id,
            maxSide: 1400,
            fit: BoxFit.contain,
            showSpinner: true,
          ),
          if (strength > 0)
            ColoredBox(color: tint.withValues(alpha: 0.28 * strength)),
          if (strength > 0)
            Positioned(
              top: 24,
              left: isKeep ? 24 : null,
              right: isKeep ? null : 24,
              child: Opacity(
                opacity: strength,
                child: _Badge(
                  label: isKeep ? AppStrings.keepLabel : AppStrings.trashLabel,
                  color: tint,
                  icon: isKeep ? Icons.favorite : Icons.delete,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color, required this.icon});

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        border: Border.all(color: color, width: 3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
