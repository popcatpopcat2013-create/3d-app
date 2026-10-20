import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_swipe/core/format.dart';
import 'package:photo_swipe/core/strings.dart';
import 'package:photo_swipe/core/theme.dart';
import 'package:photo_swipe/features/library/library_controller.dart';
import 'package:photo_swipe/features/trash/widgets/confirm_empty_trash_dialog.dart';
import 'package:photo_swipe/features/trash/widgets/trash_grid.dart';
import 'package:photo_swipe/features/trash/widgets/trash_photo_viewer.dart';
import 'package:photo_swipe/models/photo_item.dart';
import 'package:photo_swipe/models/photo_status.dart';
import 'package:photo_swipe/shared/widgets/status_message.dart';

/// Photos swiped left wait here. Nothing is deleted from the phone until
/// the user taps "empty trash" and confirms.
class TrashScreen extends ConsumerWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(libraryProvider);

    return SafeArea(
      child: library.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const StatusMessage(
          icon: Icons.error_outline,
          title: AppStrings.loadFailed,
        ),
        data: (snapshot) => _TrashBody(trashed: snapshot.trashed),
      ),
    );
  }
}

class _TrashBody extends ConsumerWidget {
  const _TrashBody({required this.trashed});

  final List<PhotoItem> trashed;

  Future<void> _openPhoto(
    BuildContext context,
    WidgetRef ref,
    PhotoItem photo,
  ) async {
    final restore = await showTrashPhotoViewer(context, photo);
    if (restore != true) return;

    ref.read(libraryProvider.notifier).decide(photo, PhotoStatus.kept);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text(AppStrings.restoredSnack)));
  }

  Future<void> _emptyTrash(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmEmptyTrashDialog(context, trashed.length);
    if (confirmed != true) return;

    String message;
    try {
      final deleted = await ref.read(libraryProvider.notifier).emptyTrash();
      message = deleted > 0
          ? AppStrings.deletedSnack(formatCount(deleted))
          : AppStrings.deleteCancelledSnack;
    } catch (_) {
      message = AppStrings.deleteFailedSnack;
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Row(
            children: [
              Text(
                AppStrings.trashTitle,
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(width: 12),
              Text(
                AppStrings.trashCount(formatCount(trashed.length)),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: Text(
            AppStrings.trashHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ),
        Expanded(
          child: trashed.isEmpty
              ? const StatusMessage(
                  icon: Icons.delete_outline,
                  title: AppStrings.trashEmpty,
                )
              : TrashGrid(
                  photos: trashed,
                  onOpen: (photo) => _openPhoto(context, ref, photo),
                ),
        ),
        if (trashed.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: () => _emptyTrash(context, ref),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.trash,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.delete_forever),
                label: const Text(AppStrings.emptyTrashButton),
              ),
            ),
          ),
      ],
    );
  }
}
