import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'palette.dart';

enum PaperPattern { none, grain, lines, dots, grid, blobs, stars, confetti, hearts }

/// A page background for entries ("Arka Plan").
class PaperSpec {
  const PaperSpec({
    required this.id,
    required this.name,
    this.base,
    this.base2,
    this.pattern = PaperPattern.none,
    this.patternColors = const [],
    this.dark = false,
    this.isPro = false,
  });

  final String id;
  final String Function(AppLocalizations) name;

  /// null = follow the app theme background.
  final Color? base;
  final Color? base2;
  final PaperPattern pattern;
  final List<Color> patternColors;
  final bool dark;
  final bool isPro;

  bool isDarkOn(AppPalette p) => base == null ? p.isDark : dark;
}

abstract final class Papers {
  static PaperSpec byId(String? id) => all.firstWhere((p) => p.id == id, orElse: () => all.first);

  static final all = <PaperSpec>[
    PaperSpec(id: 'plain', name: (l) => l.paperPlain),
    PaperSpec(
      id: 'cream',
      name: (l) => l.paperCream,
      base: const Color(0xFFFBF4E6),
      base2: const Color(0xFFF7EEDC),
      pattern: PaperPattern.grain,
      patternColors: const [Color(0xFF8A6A3A)],
    ),
    PaperSpec(
      id: 'lined',
      name: (l) => l.paperLined,
      base: const Color(0xFFFFFDF7),
      pattern: PaperPattern.lines,
      patternColors: const [Color(0xFFCADDF0), Color(0xFFF2B9B6)],
    ),
    PaperSpec(
      id: 'dots',
      name: (l) => l.paperDots,
      base: const Color(0xFFFFFDFA),
      pattern: PaperPattern.dots,
      patternColors: const [Color(0xFFD5CCC3)],
    ),
    PaperSpec(
      id: 'grid',
      isPro: true,
      name: (l) => l.paperGrid,
      base: const Color(0xFFFAFCFF),
      pattern: PaperPattern.grid,
      patternColors: const [Color(0xFFDCE6F2)],
    ),
    PaperSpec(
      id: 'peach',
      isPro: true,
      name: (l) => l.paperPeach,
      base: const Color(0xFFFFE6D8),
      base2: const Color(0xFFFFF7F0),
      pattern: PaperPattern.blobs,
      patternColors: const [Color(0xFFFFC9B5), Color(0xFFFFE1C2), Color(0xFFFFD0D8)],
    ),
    PaperSpec(
      id: 'mint',
      isPro: true,
      name: (l) => l.paperMint,
      base: const Color(0xFFDDF4EA),
      base2: const Color(0xFFF7FCF9),
      pattern: PaperPattern.blobs,
      patternColors: const [Color(0xFFBDE8D6), Color(0xFFD6F0E3), Color(0xFFCDEBF0)],
    ),
    PaperSpec(
      id: 'lilac',
      isPro: true,
      name: (l) => l.paperLilac,
      base: const Color(0xFFEBE2FF),
      base2: const Color(0xFFFBF8FF),
      pattern: PaperPattern.blobs,
      patternColors: const [Color(0xFFDCCBFF), Color(0xFFF3D3EC), Color(0xFFD3DCFF)],
    ),
    PaperSpec(
      id: 'kraft',
      isPro: true,
      name: (l) => l.paperKraft,
      base: const Color(0xFFE2C79F),
      base2: const Color(0xFFD9BA8C),
      pattern: PaperPattern.grain,
      patternColors: const [Color(0xFF6B4A22)],
    ),
    PaperSpec(
      id: 'confetti',
      isPro: true,
      name: (l) => l.paperConfetti,
      base: const Color(0xFFFFFDF8),
      pattern: PaperPattern.confetti,
      patternColors: const [Color(0xFFFFB4A2), Color(0xFFFFD670), Color(0xFF9AD9C8), Color(0xFFB9A7F5), Color(0xFF8CC8FF)],
    ),
    PaperSpec(
      id: 'hearts',
      isPro: true,
      name: (l) => l.paperHearts,
      base: const Color(0xFFFFF1F4),
      pattern: PaperPattern.hearts,
      patternColors: const [Color(0xFFF7B3C4)],
    ),
    PaperSpec(
      id: 'night',
      isPro: true,
      dark: true,
      name: (l) => l.paperNight,
      base: const Color(0xFF1A2044),
      base2: const Color(0xFF2B2452),
      pattern: PaperPattern.stars,
      patternColors: const [Color(0xFFFFFFFF), Color(0xFFFFE3A0)],
    ),
  ];
}

class PaperPainter extends CustomPainter {
  const PaperPainter(this.spec, this.fallback, {this.scale = 1});

  final PaperSpec spec;
  final Color fallback;

  /// Pattern density for thumbnails (<1 makes patterns smaller).
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final base = spec.base ?? fallback;
    if (spec.base2 != null) {
      canvas.drawRect(
        rect,
        Paint()..shader = ui.Gradient.linear(rect.topCenter, rect.bottomCenter, [base, spec.base2!]),
      );
    } else {
      canvas.drawRect(rect, Paint()..color = base);
    }
    final colors = spec.patternColors;
    final s = scale;
    switch (spec.pattern) {
      case PaperPattern.none:
        break;
      case PaperPattern.grain:
        final rnd = math.Random(3);
        final paint = Paint();
        final count = (size.width * size.height / (140 * s * s)).clamp(50, 9000).toInt();
        for (var i = 0; i < count; i++) {
          paint.color = colors.first.withValues(alpha: 0.025 + rnd.nextDouble() * 0.05);
          canvas.drawCircle(Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height), (0.5 + rnd.nextDouble()) * s, paint);
        }
      case PaperPattern.lines:
        final line = Paint()
          ..color = colors.first
          ..strokeWidth = 1;
        for (var y = 110.0 * s; y < size.height; y += 32 * s) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
        }
        canvas.drawLine(
          Offset(34 * s, 0),
          Offset(34 * s, size.height),
          Paint()
            ..color = colors.last
            ..strokeWidth = 1.2,
        );
      case PaperPattern.dots:
        final dot = Paint()..color = colors.first;
        for (var y = 18.0 * s; y < size.height; y += 24 * s) {
          for (var x = 18.0 * s; x < size.width; x += 24 * s) {
            canvas.drawCircle(Offset(x, y), 1.4 * s, dot);
          }
        }
      case PaperPattern.grid:
        final line = Paint()
          ..color = colors.first
          ..strokeWidth = 0.8;
        for (var y = 0.0; y < size.height; y += 24 * s) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
        }
        for (var x = 0.0; x < size.width; x += 24 * s) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), line);
        }
      case PaperPattern.blobs:
        final rnd = math.Random(5);
        for (var i = 0; i < 6; i++) {
          final c = Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height);
          final r = size.shortestSide * (0.35 + rnd.nextDouble() * 0.45);
          final color = colors[i % colors.length];
          canvas.drawCircle(
            c,
            r,
            Paint()..shader = ui.Gradient.radial(c, r, [color.withValues(alpha: 0.75), color.withValues(alpha: 0)]),
          );
        }
      case PaperPattern.stars:
        final rnd = math.Random(9);
        final count = (size.width * size.height / (2600 * s * s)).clamp(20, 600).toInt();
        for (var i = 0; i < count; i++) {
          final p = Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height);
          final paint = Paint()..color = colors[rnd.nextInt(colors.length)].withValues(alpha: 0.4 + rnd.nextDouble() * 0.5);
          final r = (0.6 + rnd.nextDouble() * 1.2) * s;
          canvas.drawCircle(p, r, paint);
          if (rnd.nextDouble() < 0.08) {
            paint.color = paint.color.withValues(alpha: 0.35);
            canvas.drawRect(Rect.fromCenter(center: p, width: r * 7, height: r * 0.6), paint);
            canvas.drawRect(Rect.fromCenter(center: p, width: r * 0.6, height: r * 7), paint);
          }
        }
      case PaperPattern.confetti:
        final rnd = math.Random(13);
        final count = (size.width * size.height / (3200 * s * s)).clamp(16, 400).toInt();
        for (var i = 0; i < count; i++) {
          final paint = Paint()..color = colors[rnd.nextInt(colors.length)].withValues(alpha: 0.55);
          canvas.save();
          canvas.translate(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height);
          canvas.rotate(rnd.nextDouble() * math.pi);
          if (rnd.nextBool()) {
            canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: 9 * s, height: 3.6 * s), Radius.circular(2 * s)), paint);
          } else {
            canvas.drawCircle(Offset.zero, 2.6 * s, paint);
          }
          canvas.restore();
        }
      case PaperPattern.hearts:
        final paint = Paint()..color = colors.first.withValues(alpha: 0.55);
        var row = 0;
        for (var y = 20.0 * s; y < size.height + 20; y += 40 * s, row++) {
          for (var x = (row.isOdd ? 34.0 : 14.0) * s; x < size.width + 20; x += 40 * s) {
            canvas.drawPath(_heart(Offset(x, y), 5.5 * s), paint);
          }
        }
    }
  }

  static Path _heart(Offset c, double r) => Path()
    ..moveTo(c.dx, c.dy + r * 0.9)
    ..cubicTo(c.dx - r * 1.6, c.dy - r * 0.1, c.dx - r * 0.7, c.dy - r * 1.3, c.dx, c.dy - r * 0.45)
    ..cubicTo(c.dx + r * 0.7, c.dy - r * 1.3, c.dx + r * 1.6, c.dy - r * 0.1, c.dx, c.dy + r * 0.9)
    ..close();

  @override
  bool shouldRepaint(PaperPainter old) => old.spec != spec || old.fallback != fallback || old.scale != scale;
}
