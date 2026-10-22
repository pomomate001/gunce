import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../core/widgets.dart';
import '../../data/entry.dart';
import '../../data/stickers.dart';

/// Claims the pointer immediately so the page does not scroll while a sticker is dragged.
class _EagerScale extends ScaleGestureRecognizer {
  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    resolve(GestureDisposition.accepted);
  }
}

class _EagerPan extends PanGestureRecognizer {
  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    resolve(GestureDisposition.accepted);
  }
}

/// One placed sticker: drag to move, pinch to scale/rotate, or use the corner handle.
class StickerView extends StatefulWidget {
  const StickerView({
    super.key,
    required this.item,
    required this.pageWidth,
    required this.selected,
    required this.onSelect,
    required this.onChanged,
    required this.onDelete,
    this.editable = true,
  });

  final StickerItem item;
  final double pageWidth;
  final bool selected;
  final VoidCallback onSelect;
  final ValueChanged<StickerItem> onChanged;
  final VoidCallback onDelete;
  final bool editable;

  static const minSize = 0.12;
  static const maxSize = 0.9;

  @override
  State<StickerView> createState() => _StickerViewState();
}

class _StickerViewState extends State<StickerView> {
  late StickerItem _start;
  Offset _focalStart = Offset.zero;
  Offset _handleVector = Offset.zero;

  StickerItem get item => widget.item;
  double get w => widget.pageWidth;

  StickerItem _clamp(StickerItem s) => s.copyWith(
        x: s.x.clamp(0.04, 0.96),
        y: math.max(0.04, s.y),
        size: s.size.clamp(StickerView.minSize, StickerView.maxSize),
      );

  void _onScaleStart(ScaleStartDetails d) {
    widget.onSelect();
    _start = item;
    _focalStart = d.focalPoint;
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    final delta = d.focalPoint - _focalStart;
    widget.onChanged(_clamp(_start.copyWith(
      x: _start.x + delta.dx / w,
      y: _start.y + delta.dy / w,
      size: _start.size * d.scale,
      rotation: _start.rotation + d.rotation,
    )));
  }

  void _onHandleStart(DragStartDetails d, Offset center) {
    _start = item;
    _handleVector = d.globalPosition - center;
  }

  void _onHandleUpdate(DragUpdateDetails d, Offset center) {
    final v = d.globalPosition - center;
    if (_handleVector.distance < 1) return;
    widget.onChanged(_clamp(_start.copyWith(
      size: _start.size * v.distance / _handleVector.distance,
      rotation: _start.rotation + (v.direction - _handleVector.direction),
    )));
  }

  @override
  Widget build(BuildContext context) {
    final size = item.size * w;
    final p = context.pal;
    final image = Image.asset(stickerAsset(item.sticker), width: size, height: size, filterQuality: FilterQuality.medium);
    if (!widget.editable) {
      return Transform.rotate(angle: item.rotation, child: image);
    }
    return SizedBox(
      width: size + 40,
      height: size + 40,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: RawGestureDetector(
              behavior: HitTestBehavior.translucent,
              gestures: {
                _EagerScale: GestureRecognizerFactoryWithHandlers<_EagerScale>(
                  _EagerScale.new,
                  (r) => r
                    ..onStart = _onScaleStart
                    ..onUpdate = _onScaleUpdate,
                ),
              },
              child: Center(
                child: Transform.rotate(
                  angle: item.rotation,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: widget.selected ? p.accent.withValues(alpha: 0.9) : Colors.transparent,
                        width: 1.6,
                        strokeAlign: BorderSide.strokeAlignOutside,
                      ),
                    ),
                    child: image,
                  ),
                ),
              ),
            ),
          ),
          if (widget.selected) ...[
            Positioned(
              left: 2,
              top: 2,
              child: _Handle(icon: Ph.trash, color: const Color(0xFFE5484D), onTap: widget.onDelete),
            ),
            Positioned(
              right: 2,
              bottom: 2,
              child: Builder(builder: (ctx) {
                Offset center() {
                  final box = context.findRenderObject() as RenderBox;
                  return box.localToGlobal(box.size.center(Offset.zero));
                }

                return RawGestureDetector(
                  gestures: {
                    _EagerPan: GestureRecognizerFactoryWithHandlers<_EagerPan>(
                      _EagerPan.new,
                      (r) => r
                        ..onStart = ((d) => _onHandleStart(d, center()))
                        ..onUpdate = ((d) => _onHandleUpdate(d, center())),
                    ),
                  },
                  child: _Handle(icon: Ph.arrowsOut, color: p.accent),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }
}

/// A photo or voice note on the page. Unselected it scrolls with the page and its
/// own buttons work; tap selects it, then it can be dragged, pinched or resized with
/// the corner handle like a sticker. A tap on the selected item calls [onTap].
class MediaView extends StatefulWidget {
  const MediaView({
    super.key,
    required this.layout,
    required this.pageWidth,
    required this.heightFor,
    required this.minSize,
    required this.selected,
    required this.onSelect,
    required this.onChanged,
    required this.onTap,
    required this.child,
    this.onDelete,
    this.onFrame,
  });

  final MediaLayout layout;
  final double pageWidth;

  /// Height in pixels of the item when it is [width] pixels wide.
  final double Function(double width) heightFor;
  final double minSize;
  final bool selected;
  final VoidCallback onSelect;
  final ValueChanged<MediaLayout> onChanged;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onFrame;
  final Widget child;

  @override
  State<MediaView> createState() => _MediaViewState();
}

class _MediaViewState extends State<MediaView> {
  late MediaLayout _start;
  Offset _focalStart = Offset.zero;
  Offset _handleVector = Offset.zero;
  bool _moved = false;

  MediaLayout get item => widget.layout;
  double get w => widget.pageWidth;

  MediaLayout _clamp(MediaLayout l) {
    final size = l.size.clamp(widget.minSize, 1.0);
    final halfHeight = widget.heightFor(size * w) / 2 / w;
    return l.copyWith(size: size, x: l.x.clamp(size / 2, 1 - size / 2), y: math.max(halfHeight, l.y));
  }

  void _onScaleStart(ScaleStartDetails d) {
    _start = item;
    _focalStart = d.focalPoint;
    _moved = false;
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    final delta = d.focalPoint - _focalStart;
    if (delta.distance > 6 || (d.scale - 1).abs() > 0.03) _moved = true;
    if (!_moved) return;
    widget.onChanged(_clamp(_start.copyWith(x: _start.x + delta.dx / w, y: _start.y + delta.dy / w, size: _start.size * d.scale)));
  }

  void _onScaleEnd(ScaleEndDetails d) {
    if (!_moved) widget.onTap();
  }

  void _onHandleStart(DragStartDetails d, Offset center) {
    _start = item;
    _handleVector = d.globalPosition - center;
  }

  void _onHandleUpdate(DragUpdateDetails d, Offset center) {
    if (_handleVector.dx.abs() < 1) return;
    final v = d.globalPosition - center;
    widget.onChanged(_clamp(_start.copyWith(size: _start.size * v.dx.abs() / _handleVector.dx.abs())));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final width = item.size * w;
    final height = widget.heightFor(width);
    final body = widget.selected
        ? RawGestureDetector(
            behavior: HitTestBehavior.opaque,
            gestures: {
              _EagerScale: GestureRecognizerFactoryWithHandlers<_EagerScale>(
                _EagerScale.new,
                (r) => r
                  ..onStart = _onScaleStart
                  ..onUpdate = _onScaleUpdate
                  ..onEnd = _onScaleEnd,
              ),
            },
            child: widget.child,
          )
        : GestureDetector(behavior: HitTestBehavior.opaque, onTap: widget.onSelect, child: widget.child);
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: body),
          if (widget.selected) ...[
            Positioned(
              left: -4,
              top: -4,
              right: -4,
              bottom: -4,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: p.accent.withValues(alpha: 0.9), width: 1.6),
                  ),
                ),
              ),
            ),
            if (widget.onDelete != null)
              Positioned(left: 6, top: 6, child: _Handle(icon: Ph.trash, color: const Color(0xFFE5484D), onTap: widget.onDelete)),
            if (widget.onFrame != null) Positioned(right: 6, top: 6, child: _Handle(icon: Ph.frameCorners, color: p.accent, onTap: widget.onFrame)),
            Positioned(
              right: 6,
              bottom: (height - 30).clamp(0, 6).toDouble(),
              child: Builder(builder: (ctx) {
                Offset center() {
                  final box = context.findRenderObject() as RenderBox;
                  return box.localToGlobal(box.size.center(Offset.zero));
                }

                return RawGestureDetector(
                  gestures: {
                    _EagerPan: GestureRecognizerFactoryWithHandlers<_EagerPan>(
                      _EagerPan.new,
                      (r) => r
                        ..onStart = ((d) => _onHandleStart(d, center()))
                        ..onUpdate = ((d) => _onHandleUpdate(d, center())),
                    ),
                  },
                  child: _Handle(icon: Ph.arrowsOut, color: p.accent),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }
}

class _Handle extends StatelessWidget {
  const _Handle({required this.icon, required this.color, this.onTap});
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dot = Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Icon(icon, size: 16, color: color),
    );
    return onTap == null ? dot : GestureDetector(onTap: onTap, child: dot);
  }
}
