import 'dart:typed_data';

import 'package:photo_swipe/data/database/decision_dao.dart';
import 'package:photo_swipe/data/gallery_source.dart';
import 'package:photo_swipe/models/library_snapshot.dart';
import 'package:photo_swipe/models/photo_item.dart';
import 'package:photo_swipe/models/photo_status.dart';

/// The single door between the screens and the data.
/// Features ask the repository; they never touch the gallery or the
/// database directly. Combining the two sources happens here.
class PhotoRepository {
  PhotoRepository({
    required GallerySource gallery,
    required DecisionDao decisions,
  })  : _gallery = gallery,
        _decisions = decisions;

  final GallerySource _gallery;
  final DecisionDao _decisions;

  // ---- Access to the gallery ----

  Future<bool> requestAccess() => _gallery.requestAccess();

  Future<void> openSettings() => _gallery.openSettings();

  // ---- Reading ----

  /// Loads the gallery and sorts every photo by what the user decided.
  Future<LibrarySnapshot> loadLibrary() async {
    final photos = await _gallery.loadAllPhotos();
    final decisions = await _decisions.getAll();
    final byId = {for (final photo in photos) photo.id: photo};

    final kept = <PhotoItem>[];
    final trashed = <PhotoItem>[];
    final decidedIds = <String>{};

    for (final decision in decisions) {
      final photo = byId[decision.photoId];
      // The photo may have been deleted outside the app: ignore its decision.
      if (photo == null) continue;
      decidedIds.add(decision.photoId);
      if (decision.status == PhotoStatus.trashed) {
        trashed.add(photo);
      } else {
        kept.add(photo);
      }
    }

    final undecided = [
      for (final photo in photos)
        if (!decidedIds.contains(photo.id)) photo,
    ];

    return LibrarySnapshot(undecided: undecided, kept: kept, trashed: trashed);
  }

  Future<Uint8List?> thumbnail(String id, {required int maxSide}) =>
      _gallery.thumbnail(id, maxSide: maxSide);

  // ---- Writing ----

  Future<void> saveDecision(String photoId, PhotoStatus status) =>
      _decisions.upsert(photoId, status);

  /// Deletes photos from the device and forgets their decisions.
  /// Returns the ids that were really deleted.
  Future<List<String>> deletePhotos(List<String> ids) async {
    final deleted = await _gallery.deletePhotos(ids);
    await _decisions.removeMany(deleted);
    return deleted;
  }
}
