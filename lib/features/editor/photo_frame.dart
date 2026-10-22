import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/widgets.dart';
import '../../l10n/app_localizations.dart';

/// Frames a photo can be shown in. Sizes are fractions of the framed width,
/// so a frame looks the same at every size.
enum PhotoFrame {
  none,
  polaroid,
  tape,
  stamp,
  film;

  static PhotoFrame byId(String? id) => values.firstWhere((f) => f.name == id, orElse: () => none);

  String label(AppLocalizations l) => switch (this) {
        none => l.frameNone,
        polaroid => l.framePolaroid,
        tape => l.frameTape,
        stamp => l.frameStamp,
        film => l.frameFilm,
      };

  /// Space between the outer edge of the frame and the photo.
  EdgeInsets padding(double w) => switch (this) {
        none || tape => EdgeInsets.zero,
        polaroid => EdgeInsets.fromLTRB(w * 0.05, w * 0.05, w * 0.05, w * 0.17),
        stamp => EdgeInsets.all(w * 0.06),
        film => EdgeInsets.symmetric(horizontal: w * 0.035, vertical: w * 0.1),
      };

  /// Height of a framed photo [w] wide whose image is height/width = [aspect].
  double height(double w, double aspect) {
    final pad = padding(w);
    return (w - pad.horizontal) * aspect + pad.vertical;
  }
}

/// A photo drawn inside a [PhotoFrame], exactly [width] x [PhotoFrame.height] in size.
class FramedPhoto extends StatelessWidget {
  const FramedPhoto({super.key, required this.image, required this.frame, required this.width, required this.aspect});

  final ImageProvider image;
  final PhotoFrame frame;
  final double width;
  final double aspect;

  @override
  Widget build(BuildContext context) {
    final w = width;
    final h = frame.height(w, aspect);
    final pad = frame.padding(w);
    final photo = Image(image: image, width: w - pad.horizontal, height: h - pad.vertical, fit: BoxFit.cover, gaplessPlayback: true);
    final shadow = [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: w * 0.04, offset: Offset(0, w * 0.012))];
    return SizedBox(
      width: w,
      height: h,
      child: switch (frame) {
        PhotoFrame.none => ClipRRect(borderRadius: BorderRadius.circular(math.min(24, w * 0.07)), child: photo),
        PhotoFrame.polaroid => Container(
            padding: pad,
            decoration: BoxDecoration(color: const Color(0xFFFFFDF8), borderRadius: BorderRadius.circular(3), boxShadow: shadow),
            child: photo,
          ),
        PhotoFrame.tape => Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), boxShadow: shadow),
                  child: ClipRRect(borderRadius: BorderRadius.circular(3), child: photo),
                ),
              ),
              Positioned(left: -w * 0.07, top: -w * 0.005, child: _Tape(width: w * 0.3, angle: -0.72)),
              Positioned(right: -w * 0.07, top: -w * 0.005, child: _Tape(width: w * 0.3, angle: 0.72)),
            ],
          ),
        PhotoFrame.stamp => CustomPaint(painter: _StampPainter(), child: Padding(padding: pad, child: photo)),
        PhotoFrame.film => CustomPaint(painter: _FilmPainter(pad.top), child: Padding(padding: pad, child: photo)),
      },
    );
  }
}

/// A strip of washi tape holding a corner of the photo.
class _Tape extends StatelessWidget {
  const _Tape({required this.width, required this.angle});
  final double width;
  final double angle;

  @override
  Widget build(BuildContext context) => Transform.rotate(
        angle: angle,
        child: Container(
          width: width,
          height: width * 0.26,
          decoration: BoxDecoration(
            color: const Color(0xFFF3D9A4).withValues(alpha: 0.82),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 2)],
          ),
        ),
      );
}

/// White postage stamp with a perforated edge.
class _StampPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width * 0.018;
    var path = Path()..addRect(Offset.zero & size);
    final holes = Path();
    void edge(Offset from, Offset to) {
      final n = math.max(2, ((to - from).distance / (r * 2.8)).round());
      for (var i = 0; i <= n; i++) {
        holes.addOval(Rect.fromCircle(center: Offset.lerp(from, to, i / n)!, radius: r));
      }
    }

    edge(Offset.zero, Offset(size.width, 0));
    edge(Offset(0, size.height), Offset(size.width, size.height));
    edge(Offset.zero, Offset(0, size.height));
    edge(Offset(size.width, 0), Offset(size.width, size.height));
    path = Path.combine(PathOperation.difference, path, holes);
    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.5), size.width * 0.012, false);
    canvas.drawPath(path, Paint()..color = const Color(0xFFFFFDF8));
  }

  @override
  bool shouldRepaint(_StampPainter old) => false;
}

/// A frame of film with sprocket holes above and below the picture.
class _FilmPainter extends CustomPainter {
  _FilmPainter(this.band);
  final double band;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    canvas.drawRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(w * 0.015)), Paint()..color = const Color(0xFF1F1B1E));
    final hole = Paint()..color = const Color(0xFFF4EEE6).withValues(alpha: 0.9);
    final hw = w * 0.04, hh = band * 0.36, step = w * 0.08;
    for (var x = step * 0.5; x < w - hw; x += step) {
      for (final y in [(band - hh) / 2, size.height - band + (band - hh) / 2]) {
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, hw, hh), Radius.circular(hw * 0.25)), hole);
      }
    }
  }

  @override
  bool shouldRepaint(_FilmPainter old) => old.band != band;
}

/// Frame picker for one photo. [onPick] is called on every change, so the page updates live.
Future<void> showPhotoFrameSheet(
  BuildContext context, {
  required ImageProvider image,
  required double aspect,
  required PhotoFrame current,
  required ValueChanged<PhotoFrame> onPick,
  required VoidCallback onFullScreen,
}) =>
    showAppSheet<void>(
      context,
      (_) => _FrameSheet(image: image, aspect: aspect, current: current, onPick: onPick, onFullScreen: onFullScreen),
    );

class _FrameSheet extends StatefulWidget {
  const _FrameSheet({required this.image, required this.aspect, required this.current, required this.onPick, required this.onFullScreen});
  final ImageProvider image;
  final double aspect;
  final PhotoFrame current;
  final ValueChanged<PhotoFrame> onPick;
  final VoidCallback onFullScreen;

  @override
  State<_FrameSheet> createState() => _FrameSheetState();
}

class _FrameSheetState extends State<_FrameSheet> {
  late PhotoFrame _sel = widget.current;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final l = context.l;
    const thumb = 84.0;
    // Keep tall photos from making the row huge.
    final aspect = widget.aspect.clamp(0.6, 1.2);
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SheetHeader(title: l.photoFrame, action: l.done),
          SizedBox(
            height: PhotoFrame.polaroid.height(thumb, aspect) + 56,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              scrollDirection: Axis.horizontal,
              itemCount: PhotoFrame.values.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (_, i) {
                final f = PhotoFrame.values[i];
                final sel = f == _sel;
                return Pressable(
                  onTap: () {
                    setState(() => _sel = f);
                    widget.onPick(f);
                  },
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: sel ? p.accentSoft : p.surface2,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: sel ? p.accent.withValues(alpha: 0.6) : Colors.transparent, width: 1.6),
                        ),
                        child: SizedBox(
                          height: PhotoFrame.polaroid.height(thumb, aspect),
                          child: Center(child: FramedPhoto(image: widget.image, frame: f, width: thumb, aspect: aspect)),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(f.label(l), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: sel ? p.accent : p.inkSoft)),
                    ],
                  ),
                );
              },
            ),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              widget.onFullScreen();
            },
            icon: Icon(Ph.cornersOut, color: p.accent, size: 20),
            label: Text(l.fullScreen, style: TextStyle(color: p.accent, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
