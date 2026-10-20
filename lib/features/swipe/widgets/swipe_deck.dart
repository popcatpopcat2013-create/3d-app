import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_swipe/features/swipe/widgets/photo_card_face.dart';
import 'package:photo_swipe/models/photo_item.dart';
import 'package:photo_swipe/models/photo_status.dart';

/// A stack of photo cards. Drag the top card right to keep, left to trash.
/// Let go early and it springs back. The buttons below the deck call
/// [SwipeDeckState.swipe] to do the same thing without dragging.
///
/// The deck only moves cards and reports the decision through [onSwiped].
/// It does not save anything itself.
class SwipeDeck extends StatefulWidget {
  const SwipeDeck({super.key, required this.photos, required this.onSwiped});

  /// Photos still to review. The first one is the card on top.
  final List<PhotoItem> photos;

  final void Function(PhotoItem photo, PhotoStatus status) onSwiped;

  @override
  State<SwipeDeck> createState() => SwipeDeckState();
}

class SwipeDeckState extends State<SwipeDeck>
    with SingleTickerProviderStateMixin {
  /// How far (as a share of the width) a drag must go to count as a decision.
  static const _commitFraction = 0.28;

  /// A quick flick faster than this (pixels per second) also counts.
  static const _flingSpeed = 900.0;

  late final AnimationController _animation = AnimationController(vsync: this);

  Offset _offset = Offset.zero;
  Offset _from = Offset.zero;
  Offset _to = Offset.zero;
  Curve _curve = Curves.easeOut;

  /// True while a card is flying away or springing back.
  bool _busy = false;
  double _width = 1;

  @override
  void initState() {
    super.initState();
    _animation.addListener(_onTick);
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  void _onTick() {
    setState(() {
      _offset = Offset.lerp(_from, _to, _curve.transform(_animation.value))!;
    });
  }

  Future<void> _animateTo(
    Offset target, {
    required Duration duration,
    required Curve curve,
  }) async {
    _from = _offset;
    _to = target;
    _curve = curve;
    _animation.duration = duration;
    await _animation.forward(from: 0);
  }

  /// Sends the top card away as if it was swiped. Used by the buttons.
  Future<void> swipe(PhotoStatus status) async {
    if (_busy || widget.photos.isEmpty) return;
    _busy = true;

    final photo = widget.photos.first;
    final direction = status == PhotoStatus.kept ? 1.0 : -1.0;
    HapticFeedback.lightImpact();

    await _animateTo(
      Offset(direction * _width * 1.5, _offset.dy),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeIn,
    );
    if (!mounted) return;

    // Report, then reset the card position in the same frame, so the next
    // photo appears centered with no flicker.
    widget.onSwiped(photo, status);
    setState(() {
      _offset = Offset.zero;
      _busy = false;
    });
  }

  Future<void> _springBack() async {
    _busy = true;
    await _animateTo(
      Offset.zero,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
    );
    if (!mounted) return;
    setState(() => _busy = false);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_busy) return;
    setState(() => _offset += details.delta);
  }

  void _onPanEnd(DragEndDetails details) {
    if (_busy) return;

    final dx = _offset.dx;
    final speed = details.velocity.pixelsPerSecond.dx;

    if (dx.abs() > _width * _commitFraction) {
      swipe(dx > 0 ? PhotoStatus.kept : PhotoStatus.trashed);
    } else if (speed.abs() > _flingSpeed && dx != 0 && speed.sign == dx.sign) {
      swipe(speed > 0 ? PhotoStatus.kept : PhotoStatus.trashed);
    } else {
      _springBack();
    }
  }

  /// One card. Every card is built the same way (translate, rotate, scale),
  /// so Flutter can move a card from "behind" to "on top" without
  /// rebuilding its picture.
  Widget _card(
    PhotoItem photo, {
    Offset offset = Offset.zero,
    double angle = 0,
    double scale = 1,
    double keepAmount = 0,
  }) {
    return Transform.translate(
      key: ValueKey(photo.id),
      offset: offset,
      child: Transform.rotate(
        angle: angle,
        alignment: const Alignment(0, 0.9),
        child: Transform.scale(
          scale: scale,
          child: PhotoCardFace(photo: photo, keepAmount: keepAmount),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.photos;
    if (photos.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        _width = constraints.maxWidth;

        // -1 (full trash) .. 1 (full keep)
        final keepAmount =
            (_offset.dx / (_width * _commitFraction)).clamp(-1.0, 1.0);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            children: [
              if (photos.length > 1)
                _card(photos[1], scale: 0.94 + 0.06 * keepAmount.abs()),
              _card(
                photos[0],
                offset: _offset,
                angle: _offset.dx / _width * 0.3,
                keepAmount: keepAmount,
              ),
            ],
          ),
        );
      },
    );
  }
}
