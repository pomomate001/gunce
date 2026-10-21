import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Procedural, gently animated landscapes used as theme artwork. Everything is
/// vector-drawn, so themes cost no asset space and stay crisp at any size.

enum Celestial { none, sun, moon, crescent }

enum RidgeKind { mountain, hill, dune }

enum TreeKind { pine, round }

enum Particles { none, snow, petals, fireflies, leaves }

class Bump {
  const Bump(this.x, this.h, this.w, [this.skew = 0]);

  /// Centre (fraction of width), height (fraction of height), half width (fraction of width).
  final double x, h, w;

  /// -1..1, stretches one side of the bump (dunes, leaning peaks).
  final double skew;
}

class Ridge {
  const Ridge({
    required this.color,
    this.bottom,
    required this.base,
    this.bumps = const [],
    this.kind = RidgeKind.hill,
    this.rough = 0,
    this.seed = 1,
    this.snowLine,
    this.snowColor = const Color(0xFFF7FAFF),
    this.shade = 0,
    this.trees = 0,
    this.treeKind = TreeKind.pine,
    this.treeColors = const [],
    this.treeSize = 1,
  });

  final Color color;
  final Color? bottom;
  final double base;
  final List<Bump> bumps;
  final RidgeKind kind;
  final double rough;
  final int seed;
  final double? snowLine;
  final Color snowColor;

  /// Opacity of the shadow drawn on the right flank of mountain peaks.
  final double shade;
  final int trees;
  final TreeKind treeKind;
  final List<Color> treeColors;
  final double treeSize;
}

class Water {
  const Water({required this.top, required this.colors, this.after = -1, this.shimmer});

  final double top;
  final List<Color> colors;

  /// Index of the ridge after which the water is drawn (-1: before all ridges).
  final int after;
  final Color? shimmer;
}

class Mist {
  const Mist(this.after, this.y, this.height, [this.opacity = 0.45]);
  final int after;
  final double y, height, opacity;
}

class SceneSpec {
  const SceneSpec({
    required this.sky,
    this.celestial = Celestial.none,
    this.sunPos = const Offset(0.72, 0.32),
    this.sunSize = 0.07,
    this.sunColor = const Color(0xFFFFF5D9),
    this.glow,
    this.stars = 0,
    this.aurora = const [],
    this.clouds = 0,
    this.cloudColor = const Color(0xFFFFFFFF),
    this.cloudOpacity = 0.85,
    this.ridges = const [],
    this.water,
    this.mist = const [],
    this.mistColor = const Color(0xFFFFFFFF),
    this.particles = Particles.none,
    this.particleColors = const [Color(0xFFFFFFFF)],
    this.birds = 0,
    this.birdColor = const Color(0xFF3B2C3F),
  });

  final List<Color> sky;
  final Celestial celestial;
  final Offset sunPos;
  final double sunSize;
  final Color sunColor;
  final Color? glow;
  final int stars;
  final List<Color> aurora;
  final int clouds;
  final Color cloudColor;
  final double cloudOpacity;
  final List<Ridge> ridges;
  final Water? water;
  final List<Mist> mist;
  final Color mistColor;
  final Particles particles;
  final List<Color> particleColors;
  final int birds;
  final Color birdColor;

  /// Average colour, used for placeholders and status bar contrast decisions.
  Color get tone => Color.lerp(sky.first, ridges.isEmpty ? sky.last : ridges.last.color, 0.5)!;
}

// ----------------------------------------------------------------------------

double _hash(int i, int seed) {
  var h = (i * 374761393 + seed * 668265263) & 0x7fffffff;
  h = ((h ^ (h >> 13)) * 1274126177) & 0x7fffffff;
  return (h & 0xffff) / 0xffff;
}

double _noise(double x, int seed) {
  final i = x.floor();
  final f = x - i;
  final u = f * f * (3 - 2 * f);
  return _hash(i, seed) * (1 - u) + _hash(i + 1, seed) * u;
}

double ridgeHeight(Ridge r, double x) {
  var h = 0.0;
  for (final b in r.bumps) {
    final dx = x - b.x;
    final w = b.w * (dx < 0 ? (1 - b.skew * 0.6) : (1 + b.skew * 0.6));
    final u = dx / w;
    switch (r.kind) {
      case RidgeKind.mountain:
        final a = math.sqrt(u * u + 0.0016);
        final v = a >= 1 ? 0.0 : math.pow(1 - a, 1.3).toDouble();
        h = math.max(h, b.h * v);
      case RidgeKind.hill:
        h += b.h * math.exp(-u * u * 2.2);
      case RidgeKind.dune:
        h += b.h * math.exp(-u * u * 2.6);
    }
  }
  if (r.rough > 0) {
    final n = _noise(x * 22, r.seed) * 0.7 + _noise(x * 55, r.seed + 9) * 0.3 - 0.5;
    h += r.rough * n * (r.kind == RidgeKind.mountain ? 0.25 + h * 6 : 1);
  }
  return h;
}

class SceneCache {
  Size? _size;
  SceneSpec? _spec;
  ui.Picture? back, front1, front2;

  void ensure(SceneSpec spec, Size size) {
    if (_size == size && identical(_spec, spec) && back != null) return;
    dispose();
    _size = size;
    _spec = spec;
    back = _record(size, (c) => _paintBack(c, spec, size));
    final split = spec.water?.after ?? spec.ridges.length - 1;
    front1 = _record(size, (c) => _paintRidges(c, spec, size, 0, split, withWater: true));
    front2 = _record(size, (c) => _paintRidges(c, spec, size, split + 1, spec.ridges.length - 1));
  }

  void dispose() {
    back?.dispose();
    front1?.dispose();
    front2?.dispose();
    back = front1 = front2 = null;
  }

  static ui.Picture _record(Size size, void Function(Canvas) draw) {
    final rec = ui.PictureRecorder();
    draw(Canvas(rec, Offset.zero & size));
    return rec.endRecording();
  }
}

void _paintBack(Canvas c, SceneSpec s, Size size) {
  final rect = Offset.zero & size;
  c.drawRect(
    rect,
    Paint()
      ..shader = ui.Gradient.linear(
        rect.topCenter,
        rect.bottomCenter,
        s.sky,
        [for (var i = 0; i < s.sky.length; i++) i / (s.sky.length - 1)],
      ),
  );
  if (s.celestial == Celestial.none) return;
  final center = Offset(s.sunPos.dx * size.width, s.sunPos.dy * size.height);
  final r = s.sunSize * size.width;
  final glow = s.glow ?? s.sunColor;
  final isSun = s.celestial == Celestial.sun;
  c.drawCircle(
    center,
    r * (isSun ? 5.5 : 4),
    Paint()
      ..shader = ui.Gradient.radial(center, r * (isSun ? 5.5 : 4), [
        glow.withValues(alpha: isSun ? 0.55 : 0.32),
        glow.withValues(alpha: isSun ? 0.18 : 0.08),
        glow.withValues(alpha: 0),
      ], [0, 0.35, 1]),
  );
  final disc = Paint()
    ..shader = ui.Gradient.radial(center.translate(-r * 0.3, -r * 0.3), r * 1.4, [
      Color.lerp(s.sunColor, Colors.white, 0.5)!,
      s.sunColor,
    ]);
  if (s.celestial == Celestial.crescent) {
    final moon = Path.combine(
      PathOperation.difference,
      Path()..addOval(Rect.fromCircle(center: center, radius: r)),
      Path()..addOval(Rect.fromCircle(center: center.translate(r * 0.42, -r * 0.22), radius: r * 0.9)),
    );
    c.drawPath(moon, disc);
  } else {
    c.drawCircle(center, r, disc);
    if (s.celestial == Celestial.moon) {
      final crater = Paint()..color = Colors.black.withValues(alpha: 0.06);
      c.drawCircle(center.translate(-r * 0.3, -r * 0.15), r * 0.22, crater);
      c.drawCircle(center.translate(r * 0.28, r * 0.3), r * 0.15, crater);
      c.drawCircle(center.translate(r * 0.12, -r * 0.42), r * 0.1, crater);
    }
  }
}

void _paintRidges(Canvas c, SceneSpec s, Size size, int from, int to, {bool withWater = false}) {
  if (withWater && s.water != null && s.water!.after < 0) _paintWater(c, s.water!, size);
  for (var i = from; i <= to && i < s.ridges.length; i++) {
    _paintRidge(c, s.ridges[i], size);
    for (final m in s.mist.where((m) => m.after == i)) {
      final top = (m.y - m.height / 2) * size.height;
      final rect = Rect.fromLTWH(0, top, size.width, m.height * size.height);
      c.drawRect(
        rect,
        Paint()
          ..shader = ui.Gradient.linear(rect.topCenter, rect.bottomCenter, [
            s.mistColor.withValues(alpha: 0),
            s.mistColor.withValues(alpha: m.opacity),
            s.mistColor.withValues(alpha: 0),
          ], [0, 0.55, 1]),
      );
    }
    if (withWater && s.water != null && s.water!.after == i) _paintWater(c, s.water!, size);
  }
}

void _paintWater(Canvas c, Water w, Size size) {
  final rect = Rect.fromLTRB(0, w.top * size.height, size.width, size.height);
  c.drawRect(
    rect,
    Paint()
      ..shader = ui.Gradient.linear(
        rect.topCenter,
        rect.bottomCenter,
        w.colors,
        [for (var i = 0; i < w.colors.length; i++) i / (w.colors.length - 1)],
      ),
  );
  final rnd = math.Random(7);
  final line = Paint()
    ..color = Colors.white.withValues(alpha: 0.18)
    ..strokeWidth = 1.2
    ..strokeCap = StrokeCap.round;
  for (var i = 0; i < 16; i++) {
    final y = rect.top + rect.height * (0.08 + rnd.nextDouble() * 0.9);
    final x = rnd.nextDouble() * size.width;
    final len = size.width * (0.03 + rnd.nextDouble() * 0.07) * (0.5 + (y - rect.top) / rect.height);
    c.drawLine(Offset(x, y), Offset(x + len, y), line);
  }
}

void _paintRidge(Canvas c, Ridge r, Size size) {
  const n = 120;
  final pts = <Offset>[];
  for (var i = 0; i <= n; i++) {
    final fx = -0.02 + 1.04 * i / n;
    pts.add(Offset(fx * size.width, (r.base - ridgeHeight(r, fx)) * size.height));
  }
  final path = Path()..moveTo(-4, size.height + 4);
  for (final p in pts) {
    path.lineTo(p.dx, p.dy);
  }
  path
    ..lineTo(size.width + 4, size.height + 4)
    ..close();

  final top = pts.map((p) => p.dy).reduce(math.min);
  c.drawPath(
    path,
    Paint()
      ..shader = ui.Gradient.linear(Offset(0, top), Offset(0, size.height), [r.color, r.bottom ?? r.color]),
  );

  if (r.kind == RidgeKind.mountain && (r.shade > 0 || r.snowLine != null)) {
    c.save();
    c.clipPath(path);
    if (r.snowLine != null) {
      final snow = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (final p in pts) {
        snow.lineTo(p.dx, p.dy);
      }
      for (final p in pts.reversed) {
        final fx = p.dx / size.width;
        final jag = (math.sin(fx * 90) * 0.5 + _noise(fx * 40, r.seed + 3) - 0.5) * 0.022;
        snow.lineTo(p.dx, math.max(p.dy, (r.snowLine! + jag) * size.height));
      }
      snow.close();
      c.drawPath(snow, Paint()..color = r.snowColor);
    }
    if (r.shade > 0) {
      final shadow = Paint()..color = Colors.black.withValues(alpha: r.shade);
      for (final b in r.bumps) {
        final px = b.x * size.width;
        final py = (r.base - ridgeHeight(r, b.x)) * size.height;
        final wRight = b.w * (1 + b.skew * 0.6) * size.width;
        c.drawPath(
          Path()
            ..moveTo(px, py)
            ..lineTo(px + wRight * 0.95, size.height * r.base + 2)
            ..lineTo(px + wRight * 0.12, size.height + 4)
            ..lineTo(px - wRight * 0.05, size.height + 4)
            ..close(),
          shadow,
        );
      }
    }
    c.restore();
  }

  if (r.trees > 0 && r.treeColors.isNotEmpty) {
    final rnd = math.Random(r.seed * 31 + 5);
    final trees = <(double, double, double, Color)>[];
    for (var i = 0; i < r.trees; i++) {
      final fx = rnd.nextDouble();
      final h = size.height * (0.075 + rnd.nextDouble() * 0.06) * r.treeSize;
      final y = (r.base - ridgeHeight(r, fx)) * size.height + h * (0.12 + rnd.nextDouble() * 0.25);
      trees.add((fx * size.width, y, h, r.treeColors[rnd.nextInt(r.treeColors.length)]));
    }
    trees.sort((a, b) => a.$2.compareTo(b.$2));
    for (final (x, y, h, color) in trees) {
      final paint = Paint()..color = color;
      if (r.treeKind == TreeKind.pine) {
        c.drawRect(Rect.fromLTWH(x - h * 0.035, y - h * 0.15, h * 0.07, h * 0.2), paint);
        for (var t = 0; t < 3; t++) {
          final w = h * (0.5 - t * 0.11);
          final baseY = y - h * 0.12 - t * h * 0.24;
          c.drawPath(
            Path()
              ..moveTo(x, baseY - h * 0.42)
              ..lineTo(x + w / 2, baseY)
              ..quadraticBezierTo(x, baseY + h * 0.05, x - w / 2, baseY)
              ..close(),
            paint,
          );
        }
      } else {
        c.drawRect(Rect.fromLTWH(x - h * 0.04, y - h * 0.45, h * 0.08, h * 0.5), Paint()..color = Color.lerp(color, Colors.black, 0.45)!);
        c.drawOval(Rect.fromCenter(center: Offset(x, y - h * 0.62), width: h * 0.62, height: h * 0.7), paint);
        c.drawOval(
          Rect.fromCenter(center: Offset(x - h * 0.1, y - h * 0.72), width: h * 0.26, height: h * 0.22),
          Paint()..color = Colors.white.withValues(alpha: 0.12),
        );
      }
    }
  }
}

// ----------------------------------------------------------------------------

class ScenePainter extends CustomPainter {
  ScenePainter(this.spec, this.time, this.cache) : super(repaint: time);

  final SceneSpec spec;
  final Animation<double> time;
  final SceneCache cache;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    canvas.clipRect(Offset.zero & size);
    cache.ensure(spec, size);
    final t = time.value;
    canvas.drawPicture(cache.back!);
    if (spec.stars > 0) _stars(canvas, size, t);
    if (spec.aurora.isNotEmpty) _aurora(canvas, size, t);
    if (spec.clouds > 0) _clouds(canvas, size, t);
    canvas.drawPicture(cache.front1!);
    if (spec.water?.shimmer != null && spec.celestial != Celestial.none) _shimmer(canvas, size, t);
    canvas.drawPicture(cache.front2!);
    if (spec.birds > 0) _birds(canvas, size, t);
    if (spec.particles != Particles.none) _particles(canvas, size, t);
  }

  double get _unit => 1;

  void _stars(Canvas c, Size size, double t) {
    final rnd = math.Random(11);
    final scale = (size.width / 380).clamp(0.6, 1.6);
    final sun = Offset(spec.sunPos.dx * size.width, spec.sunPos.dy * size.height);
    final avoid = spec.sunSize * size.width * 1.8;
    final paint = Paint();
    for (var i = 0; i < spec.stars; i++) {
      final p = Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * rnd.nextDouble() * size.height * 0.75);
      final r = (0.45 + rnd.nextDouble() * 1.1) * scale * _unit;
      final speed = 1 + rnd.nextInt(4);
      final phase = rnd.nextDouble();
      if (spec.celestial != Celestial.none && (p - sun).distance < avoid) continue;
      final a = 0.3 + 0.7 * (0.5 + 0.5 * math.sin(2 * math.pi * (t * speed + phase)));
      paint.color = Colors.white.withValues(alpha: a);
      c.drawCircle(p, r, paint);
      if (r > 1.25 * scale) {
        paint.color = Colors.white.withValues(alpha: a * 0.35);
        c.drawRect(Rect.fromCenter(center: p, width: r * 5, height: r * 0.5), paint);
        c.drawRect(Rect.fromCenter(center: p, width: r * 0.5, height: r * 5), paint);
      }
    }
  }

  void _aurora(Canvas c, Size size, double t) {
    for (var i = 0; i < spec.aurora.length; i++) {
      final color = spec.aurora[i];
      final baseY = size.height * (0.16 + i * 0.09);
      final thick = size.height * (0.2 - i * 0.03);
      final top = Path();
      final pts = <Offset>[];
      for (var k = 0; k <= 60; k++) {
        final fx = k / 60;
        final wave = math.sin(fx * math.pi * 2.2 + i * 1.7 + t * 2 * math.pi) * 0.5 +
            math.sin(fx * math.pi * 5 + i + t * 4 * math.pi) * 0.2;
        pts.add(Offset(fx * size.width, baseY + wave * size.height * 0.07));
      }
      top.moveTo(pts.first.dx, pts.first.dy - thick);
      for (final p in pts) {
        top.lineTo(p.dx, p.dy - thick * (0.75 + 0.25 * math.sin(p.dx / size.width * 9 + t * 2 * math.pi)));
      }
      for (final p in pts.reversed) {
        top.lineTo(p.dx, p.dy);
      }
      top.close();
      c.drawPath(
        top,
        Paint()
          ..blendMode = BlendMode.screen
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
          ..shader = ui.Gradient.linear(
            Offset(0, baseY - thick),
            Offset(0, baseY),
            [color.withValues(alpha: 0), color.withValues(alpha: 0.38), color.withValues(alpha: 0.7)],
            [0, 0.6, 1],
          ),
      );
    }
  }

  void _clouds(Canvas c, Size size, double t) {
    final rnd = math.Random(23);
    final paint = Paint()
      ..color = spec.cloudColor.withValues(alpha: spec.cloudOpacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.6);
    for (var i = 0; i < spec.clouds; i++) {
      final w = size.width * (0.16 + rnd.nextDouble() * 0.16);
      final h = w * 0.26;
      final y = size.height * (0.1 + rnd.nextDouble() * 0.28);
      final speed = 1 + rnd.nextInt(2);
      final x = ((rnd.nextDouble() + t * speed * 0.6) % 1.0) * (size.width + w * 2) - w;
      final cloud = Path()
        ..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y - h * 0.5, w, h), Radius.circular(h / 2)))
        ..addOval(Rect.fromCircle(center: Offset(x + w * 0.32, y - h * 0.45), radius: h * 0.62))
        ..addOval(Rect.fromCircle(center: Offset(x + w * 0.55, y - h * 0.7), radius: h * 0.85))
        ..addOval(Rect.fromCircle(center: Offset(x + w * 0.76, y - h * 0.35), radius: h * 0.55));
      c.drawPath(cloud, paint);
    }
  }

  void _shimmer(Canvas c, Size size, double t) {
    final w = spec.water!;
    final x = spec.sunPos.dx * size.width;
    final top = w.top * size.height;
    final r = spec.sunSize * size.width;
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(1.6, size.height * 0.008);
    var y = top + size.height * 0.012;
    for (var k = 0; k < 16 && y < size.height; k++) {
      final phase = 0.5 + 0.5 * math.sin(2 * math.pi * (t * 3 + k * 0.37));
      final len = r * (1.7 - k * 0.07) * (0.55 + 0.45 * phase);
      paint.color = w.shimmer!.withValues(alpha: (0.75 - k * 0.04).clamp(0.1, 1.0));
      c.drawLine(Offset(x - len, y), Offset(x + len, y), paint);
      y += size.height * (0.016 + k * 0.0026);
    }
  }

  void _birds(Canvas c, Size size, double t) {
    final rnd = math.Random(41);
    final paint = Paint()
      ..color = spec.birdColor.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(1.1, size.width / 320);
    for (var i = 0; i < spec.birds; i++) {
      final s = size.width * (0.011 + rnd.nextDouble() * 0.006);
      final fx = (spec.sunPos.dx - 0.22 + rnd.nextDouble() * 0.32 + t * 0.08) % 1.0;
      final x = fx * size.width;
      final y = size.height * (spec.sunPos.dy - 0.12 + rnd.nextDouble() * 0.14) + math.sin(2 * math.pi * (t * 2 + i * 0.3)) * s * 0.6;
      final flap = math.sin(2 * math.pi * (t * 40 + rnd.nextDouble())) * s * 0.35;
      c.drawPath(
        Path()
          ..moveTo(x - s, y - s * 0.25 - flap)
          ..quadraticBezierTo(x - s * 0.45, y - s * 0.55 - flap, x, y)
          ..quadraticBezierTo(x + s * 0.45, y - s * 0.55 - flap, x + s, y - s * 0.25 - flap),
        paint,
      );
    }
  }

  void _particles(Canvas c, Size size, double t) {
    final rnd = math.Random(57);
    final scale = (size.width / 380).clamp(0.6, 1.8);
    final colors = spec.particleColors;
    switch (spec.particles) {
      case Particles.snow:
        final paint = Paint();
        for (var i = 0; i < 46; i++) {
          final speed = 1 + rnd.nextInt(3);
          final y = (rnd.nextDouble() + t * speed) % 1.0;
          final x = rnd.nextDouble() + 0.02 * math.sin(2 * math.pi * (t * (1 + rnd.nextInt(3)) + rnd.nextDouble()));
          paint.color = colors.first.withValues(alpha: 0.55 + rnd.nextDouble() * 0.4);
          c.drawCircle(Offset(x * size.width, y * size.height), (0.9 + rnd.nextDouble() * 1.6) * scale, paint);
        }
      case Particles.petals:
      case Particles.leaves:
        final leaf = spec.particles == Particles.leaves;
        for (var i = 0; i < 16; i++) {
          final speed = 1 + rnd.nextInt(2);
          final fy = (rnd.nextDouble() + t * speed) % 1.0;
          final fx = (rnd.nextDouble() + fy * 0.25 + 0.03 * math.sin(2 * math.pi * (t * 3 + i * 0.2))) % 1.0;
          final angle = 2 * math.pi * (t * (1 + rnd.nextInt(3)) + rnd.nextDouble());
          final color = colors[rnd.nextInt(colors.length)];
          c.save();
          c.translate(fx * size.width, fy * size.height);
          c.rotate(angle);
          final s = (leaf ? 4.2 : 3.4) * scale;
          final paint = Paint()..color = color.withValues(alpha: 0.9);
          if (leaf) {
            c.drawPath(
              Path()
                ..moveTo(-s, 0)
                ..quadraticBezierTo(0, -s * 0.9, s, 0)
                ..quadraticBezierTo(0, s * 0.9, -s, 0),
              paint,
            );
          } else {
            c.drawOval(Rect.fromCenter(center: Offset.zero, width: s * 2, height: s * 1.15), paint);
          }
          c.restore();
        }
      case Particles.fireflies:
        for (var i = 0; i < 16; i++) {
          final x0 = rnd.nextDouble();
          final y0 = 0.55 + rnd.nextDouble() * 0.4;
          final ph = rnd.nextDouble();
          final x = x0 + 0.03 * math.sin(2 * math.pi * (t * (1 + rnd.nextInt(2)) + ph));
          final y = y0 + 0.025 * math.cos(2 * math.pi * (t * (1 + rnd.nextInt(2)) + ph));
          final a = 0.25 + 0.75 * (0.5 + 0.5 * math.sin(2 * math.pi * (t * (2 + rnd.nextInt(4)) + ph)));
          final p = Offset(x * size.width, y * size.height);
          final color = colors.first;
          c.drawCircle(
            p,
            7 * scale,
            Paint()
              ..shader = ui.Gradient.radial(p, 7 * scale, [color.withValues(alpha: a * 0.6), color.withValues(alpha: 0)]),
          );
          c.drawCircle(p, 1.4 * scale, Paint()..color = Colors.white.withValues(alpha: a));
        }
      case Particles.none:
        break;
    }
  }

  @override
  bool shouldRepaint(ScenePainter old) => old.spec != spec || old.cache != cache;
}

/// Paints a [SceneSpec]; animates slowly unless [animate] is false or the
/// platform asks for reduced motion.
class SceneView extends StatefulWidget {
  const SceneView({super.key, required this.spec, this.animate = true});

  final SceneSpec spec;
  final bool animate;

  @override
  State<SceneView> createState() => _SceneViewState();
}

class _SceneViewState extends State<SceneView> with SingleTickerProviderStateMixin {
  late final AnimationController _time = AnimationController(vsync: this, duration: const Duration(seconds: 90));
  final _cache = SceneCache();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(SceneView old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (widget.animate && !reduce) {
      if (!_time.isAnimating) _time.repeat();
    } else {
      _time.stop();
    }
  }

  @override
  void dispose() {
    _time.dispose();
    _cache.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(painter: ScenePainter(widget.spec, _time, _cache), child: const SizedBox.expand()),
    );
  }
}
