import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_swipe/data/providers.dart';

/// Shows one photo from the gallery, filling the space it is given.
class PhotoThumbnail extends ConsumerWidget {
  const PhotoThumbnail({
    super.key,
    required this.photoId,
    this.maxSide = 300,
    this.fit = BoxFit.cover,
    this.showSpinner = false,
  });

  final String photoId;

  /// Longest side, in pixels, of the picture to load.
  final int maxSide;
  final BoxFit fit;
  final bool showSpinner;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final thumbnail = ref.watch(
      thumbnailProvider((id: photoId, maxSide: maxSide)),
    );

    Widget missing() => ColoredBox(
          color: colors.surfaceContainerHighest,
          child: Center(
            child: Icon(
              Icons.broken_image_outlined,
              color: colors.onSurfaceVariant,
            ),
          ),
        );

    return thumbnail.when(
      data: (bytes) {
        if (bytes == null) return missing();
        return Image.memory(
          bytes,
          fit: fit,
          width: double.infinity,
          height: double.infinity,
          gaplessPlayback: true,
        );
      },
      loading: () => ColoredBox(
        color: colors.surfaceContainerHighest,
        child: showSpinner
            ? const Center(child: CircularProgressIndicator())
            : null,
      ),
      error: (_, __) => missing(),
    );
  }
}
