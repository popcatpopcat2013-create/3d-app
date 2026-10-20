import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_swipe/core/format.dart';
import 'package:photo_swipe/core/strings.dart';
import 'package:photo_swipe/features/library/library_controller.dart';
import 'package:photo_swipe/features/swipe/widgets/swipe_action_buttons.dart';
import 'package:photo_swipe/features/swipe/widgets/swipe_deck.dart';
import 'package:photo_swipe/models/library_snapshot.dart';
import 'package:photo_swipe/models/photo_status.dart';
import 'package:photo_swipe/shared/widgets/status_message.dart';

/// The main screen: swipe photos right to keep, left to trash.
class SwipeScreen extends ConsumerStatefulWidget {
  const SwipeScreen({super.key, required this.onOpenTrash});

  /// Called by the "go to trash" button on the "all done" view.
  final VoidCallback onOpenTrash;

  @override
  ConsumerState<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends ConsumerState<SwipeScreen> {
  final _deckKey = GlobalKey<SwipeDeckState>();

  @override
  Widget build(BuildContext context) {
    final library = ref.watch(libraryProvider);

    return SafeArea(
      child: library.when(
        loading: () => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(AppStrings.loadingLibrary),
            ],
          ),
        ),
        error: (_, __) => StatusMessage(
          icon: Icons.error_outline,
          title: AppStrings.loadFailed,
          actions: [
            FilledButton(
              onPressed: () => ref.read(libraryProvider.notifier).reload(),
              child: const Text(AppStrings.retry),
            ),
          ],
        ),
        data: _buildLibrary,
      ),
    );
  }

  Widget _buildLibrary(LibrarySnapshot library) {
    final kept = library.kept.length;
    final trashed = library.trashed.length;
    final total = library.undecided.length + kept + trashed;

    if (total == 0) {
      return const StatusMessage(
        icon: Icons.photo_outlined,
        title: AppStrings.emptyLibraryTitle,
        message: AppStrings.emptyLibraryMessage,
      );
    }

    if (library.undecided.isEmpty) {
      return StatusMessage(
        icon: Icons.celebration_outlined,
        title: AppStrings.doneTitle,
        message: AppStrings.doneSummary(formatCount(kept), formatCount(trashed)),
        actions: [
          FilledButton(
            onPressed: widget.onOpenTrash,
            child: const Text(AppStrings.doneOpenTrash),
          ),
        ],
      );
    }

    final current = library.undecided.first;
    final progress = (kept + trashed) / total;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.remaining(formatCount(library.undecided.length)),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                formatDateTime(current.createdAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(value: progress, minHeight: 6),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SwipeDeck(
              key: _deckKey,
              photos: library.undecided,
              onSwiped: (photo, status) =>
                  ref.read(libraryProvider.notifier).decide(photo, status),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: SwipeActionButtons(
            onTrash: () => _deckKey.currentState?.swipe(PhotoStatus.trashed),
            onKeep: () => _deckKey.currentState?.swipe(PhotoStatus.kept),
          ),
        ),
      ],
    );
  }
}
