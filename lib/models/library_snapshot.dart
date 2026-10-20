import 'package:photo_swipe/models/photo_item.dart';

/// Everything known about the gallery at one moment, split by decision.
class LibrarySnapshot {
  const LibrarySnapshot({
    required this.undecided,
    required this.kept,
    required this.trashed,
  });

  /// Not reviewed yet, newest first.
  final List<PhotoItem> undecided;

  /// Kept, most recently decided first.
  final List<PhotoItem> kept;

  /// Waiting in the trash, most recently trashed first.
  final List<PhotoItem> trashed;
}
