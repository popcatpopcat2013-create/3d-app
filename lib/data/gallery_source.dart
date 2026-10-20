import 'dart:math' as math;
import 'dart:typed_data';

import 'package:photo_manager/photo_manager.dart';
import 'package:photo_swipe/models/photo_item.dart';

/// The only file that talks to the phone's gallery (via photo_manager).
/// If the gallery package ever changes, this is the one place to update.
class GallerySource {
  /// Gallery entries by id, filled by [loadAllPhotos], so thumbnails do not
  /// have to look each photo up again.
  final Map<String, AssetEntity> _entities = {};

  /// Asks for access to photos (shows the system dialog if needed).
  /// Returns true when the app may read the gallery.
  Future<bool> requestAccess() async {
    final state = await PhotoManager.requestPermissionExtend(
      requestOption: const PermissionRequestOption(
        androidPermission: AndroidPermission(
          type: RequestType.image,
          mediaLocation: false,
        ),
      ),
    );
    return state == PermissionState.authorized ||
        state == PermissionState.limited;
  }

  Future<void> openSettings() => PhotoManager.openSetting();

  /// Every photo on the device, newest first.
  Future<List<PhotoItem>> loadAllPhotos() async {
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
    );
    if (albums.isEmpty) return const [];

    final everything = albums.first;
    final total = await everything.assetCountAsync;

    _entities.clear();
    final photos = <PhotoItem>[];

    // Fetch in chunks so a huge gallery does not arrive in one giant message.
    const chunkSize = 1000;
    for (var start = 0; start < total; start += chunkSize) {
      final end = math.min(start + chunkSize, total);
      final chunk = await everything.getAssetListRange(start: start, end: end);
      for (final entity in chunk) {
        _entities[entity.id] = entity;
        photos.add(PhotoItem(id: entity.id, createdAt: entity.createDateTime));
      }
    }

    photos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return photos;
  }

  /// A JPEG of the photo whose longest side is at most [maxSide] pixels.
  /// Returns null when the photo no longer exists.
  Future<Uint8List?> thumbnail(String id, {required int maxSide}) async {
    var entity = _entities[id];
    if (entity == null) {
      entity = await AssetEntity.fromId(id);
      if (entity == null) return null;
      _entities[id] = entity;
    }

    // Ask for the photo's own proportions so nothing gets cropped.
    final width = entity.orientatedWidth;
    final height = entity.orientatedHeight;
    final ThumbnailSize size;
    if (width <= 0 || height <= 0) {
      size = ThumbnailSize.square(maxSide);
    } else {
      final scale = math.min(1.0, maxSide / math.max(width, height));
      size = ThumbnailSize(
        math.max(1, (width * scale).round()),
        math.max(1, (height * scale).round()),
      );
    }
    return entity.thumbnailDataWithSize(size, quality: 85);
  }

  /// Deletes photos from the device for good. Android shows its own
  /// confirmation first. Returns the ids that were really deleted
  /// (empty if the user said no).
  Future<List<String>> deletePhotos(List<String> ids) async {
    if (ids.isEmpty) return const [];
    final deleted = await PhotoManager.editor.deleteWithIds(ids);
    for (final id in deleted) {
      _entities.remove(id);
    }
    return deleted;
  }
}
