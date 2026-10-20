/// Which photo to load a picture for, and the longest side in pixels.
/// A record, so two requests with the same values count as equal
/// (which lets the thumbnail provider cache them).
typedef ThumbnailRequest = ({String id, int maxSide});
