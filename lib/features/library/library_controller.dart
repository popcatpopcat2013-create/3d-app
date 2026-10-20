import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_swipe/data/photo_repository.dart';
import 'package:photo_swipe/data/providers.dart';
import 'package:photo_swipe/models/library_snapshot.dart';
import 'package:photo_swipe/models/photo_item.dart';
import 'package:photo_swipe/models/photo_status.dart';

/// The one shared picture of the library: which photos are waiting, kept,
/// or in the trash. The swipe screen and the trash screen both read this
/// and both change it through the methods below.
class LibraryController extends AsyncNotifier<LibrarySnapshot> {
  PhotoRepository get _repository => ref.read(photoRepositoryProvider);

  @override
  Future<LibrarySnapshot> build() => _repository.loadLibrary();

  /// Loads everything again from the gallery.
  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.loadLibrary);
  }

  /// Records a decision. The screen updates at once; saving to the
  /// database happens in the background.
  void decide(PhotoItem photo, PhotoStatus status) {
    final current = state.valueOrNull;
    if (current == null) return;

    bool isOther(PhotoItem item) => item.id != photo.id;

    final undecided = current.undecided.where(isOther).toList();
    final kept = current.kept.where(isOther).toList();
    final trashed = current.trashed.where(isOther).toList();

    if (status == PhotoStatus.kept) {
      kept.insert(0, photo);
    } else {
      trashed.insert(0, photo);
    }

    state = AsyncData(
      LibrarySnapshot(undecided: undecided, kept: kept, trashed: trashed),
    );

    _repository.saveDecision(photo.id, status).catchError((Object error) {
      debugPrint('Could not save decision for ${photo.id}: $error');
    });
  }

  /// Deletes everything in the trash from the device for good.
  /// Returns how many photos were really deleted (0 if the user cancelled
  /// Android's confirmation).
  Future<int> emptyTrash() async {
    final current = state.valueOrNull;
    if (current == null || current.trashed.isEmpty) return 0;

    final ids = [for (final photo in current.trashed) photo.id];
    final deleted = await _repository.deletePhotos(ids);
    if (deleted.isEmpty) return 0;

    final gone = deleted.toSet();
    // Read the state again: the user may have swiped while the dialog was open.
    final latest = state.valueOrNull ?? current;
    state = AsyncData(
      LibrarySnapshot(
        undecided: latest.undecided,
        kept: latest.kept.where((p) => !gone.contains(p.id)).toList(),
        trashed: latest.trashed.where((p) => !gone.contains(p.id)).toList(),
      ),
    );
    return deleted.length;
  }
}

final libraryProvider =
    AsyncNotifierProvider<LibraryController, LibrarySnapshot>(
  LibraryController.new,
);
