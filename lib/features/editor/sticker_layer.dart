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
