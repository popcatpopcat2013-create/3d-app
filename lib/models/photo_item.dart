/// One photo in the gallery. Holds only the light data the app needs;
/// the picture itself is loaded on demand (see ThumbnailRequest).
class PhotoItem {
  const PhotoItem({required this.id, required this.createdAt});

  /// The gallery's own id for this photo.
  final String id;
  final DateTime createdAt;

  @override
  bool operator ==(Object other) => other is PhotoItem && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
