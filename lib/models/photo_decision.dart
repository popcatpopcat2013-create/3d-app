import 'package:photo_swipe/models/photo_status.dart';

/// A saved decision: this photo was kept or trashed at this time.
class PhotoDecision {
  const PhotoDecision({
    required this.photoId,
    required this.status,
    required this.decidedAt,
  });

  final String photoId;
  final PhotoStatus status;
  final DateTime decidedAt;
}
