import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_swipe/data/database/app_database.dart';
import 'package:photo_swipe/data/database/decision_dao.dart';
import 'package:photo_swipe/data/gallery_source.dart';
import 'package:photo_swipe/data/photo_repository.dart';
import 'package:photo_swipe/models/thumbnail_request.dart';

/// Wiring for the data layer. Screens use [photoRepositoryProvider]
/// and [thumbnailProvider]; the others are plumbing.

final appDatabaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

final decisionDaoProvider = Provider<DecisionDao>(
  (ref) => DecisionDao(ref.watch(appDatabaseProvider)),
);

final gallerySourceProvider = Provider<GallerySource>(
  (ref) => GallerySource(),
);

final photoRepositoryProvider = Provider<PhotoRepository>(
  (ref) => PhotoRepository(
    gallery: ref.watch(gallerySourceProvider),
    decisions: ref.watch(decisionDaoProvider),
  ),
);

/// The picture for one photo at one size. Freed automatically when no
/// widget is showing it any more.
final thumbnailProvider = FutureProvider.autoDispose
    .family<Uint8List?, ThumbnailRequest>((ref, request) {
  return ref
      .watch(photoRepositoryProvider)
      .thumbnail(request.id, maxSide: request.maxSide);
});
