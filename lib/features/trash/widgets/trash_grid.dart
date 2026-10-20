import 'package:flutter/material.dart';
import 'package:photo_swipe/models/photo_item.dart';
import 'package:photo_swipe/shared/widgets/photo_thumbnail.dart';

/// The trashed photos as a grid of small squares. Tap one to open it.
class TrashGrid extends StatelessWidget {
  const TrashGrid({super.key, required this.photos, required this.onOpen});

  final List<PhotoItem> photos;
  final void Function(PhotoItem photo) onOpen;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        final photo = photos[index];
        return GestureDetector(
          key: ValueKey(photo.id),
          onTap: () => onOpen(photo),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: PhotoThumbnail(photoId: photo.id, maxSide: 300),
          ),
        );
      },
    );
  }
}
