import 'package:flutter/material.dart';
import 'package:photo_swipe/core/format.dart';
import 'package:photo_swipe/core/strings.dart';
import 'package:photo_swipe/models/photo_item.dart';
import 'package:photo_swipe/shared/widgets/photo_thumbnail.dart';

/// Opens a trashed photo large, with a restore button.
/// Resolves to true when the user chose to restore it.
Future<bool?> showTrashPhotoViewer(BuildContext context, PhotoItem photo) {
  return showDialog<bool>(
    context: context,
    builder: (context) => _TrashPhotoViewer(photo: photo),
  );
}

class _TrashPhotoViewer extends StatelessWidget {
  const _TrashPhotoViewer({required this.photo});

  final PhotoItem photo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 240),
              child: InteractiveViewer(
                maxScale: 5,
                child: PhotoThumbnail(
                  photoId: photo.id,
                  maxSide: 1600,
                  fit: BoxFit.contain,
                  showSpinner: true,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              formatDateTime(photo.createdAt),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(AppStrings.close),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(true),
                  icon: const Icon(Icons.restore),
                  label: const Text(AppStrings.restore),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
