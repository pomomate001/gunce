import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/format.dart';
import '../../core/palette.dart';
import '../../core/widgets.dart';
import '../../data/entries_controller.dart';
import '../../data/mood.dart';
import '../../data/settings.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  bool get _isCurrent {
    final now = DateTime.now();
    return _month.year == now.year && _month.month == now.month;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final l = context.l;
    final entries = context.watch<EntriesController>();
    final dates = Dates(context.lang);
    final monthEntries = entries.inRange(_month, DateTime(_month.year, _month.month + 1));
    final counts = entries.moodCounts(monthEntries);
    final total = counts.values.fold(0, (a, b) => a + b);
    final top = total == 0 ? null : (counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).first.key;
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final flow = <(int, Mood)>[
      for (var d = 1; d <= daysInMonth; d++)
        if (entries.moodOn(DateTime(_month.year, _month.month, d)) case final m?) (d, m),
    ];

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 130),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 0, 0, 14),
            child: Text(l.insightsTitle, style: context.text.displaySmall),
          ),
          const _StreakCard(),
          const SizedBox(height: 14),
          _Totals(entries: entries),
          const SizedBox(height: 22),
          Row(
            children: [
              CircleButton(icon: Ph.caretLeft, background: p.surface, onTap: () => setState(() => _month = DateTime(_month.year, _month.month - 1))),
              Expanded(child: Center(child: Text(dates.monthYear(_month), style: context.text.titleLarge))),
              Opacity(
                opacity: _isCurrent ? 0.35 : 1,
                child: CircleButton(
                  icon: Ph.caretRight,
                  background: p.surface,
                  onTap: _isCurrent ? null : () => setState(() => _month = DateTime(_month.year, _month.month + 1)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.moodBreakdown, style: context.text.titleLarge),
                const SizedBox(height: 4),
                Text(
                  top == null ? l.noMoodsYet : l.mostlyFelt(top.label(l)),
                  style: context.text.bodyMedium,
                ),
                const SizedBox(height: 18),
                AspectRatio(
                  aspectRatio: 2,
                  child: Stack(
                    children: [
                      Positioned.fill(child: CustomPaint(painter: _GaugePainter(counts, p.surface2))),
                      Align(
                        alignment: const Alignment(0, 0.75),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (top != null) MoodIcon(top, size: 46),
                            Text('$total', style: context.text.displaySmall),
                            Text(l.moodEntries, style: context.text.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.25,
                  children: [
                    for (final m in Mood.values)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Opacity(opacity: counts[m]! > 0 ? 1 : 0.45, child: MoodIcon(m, size: 34)),
                          const SizedBox(height: 4),
                          Text('${counts[m]}', style: context.text.titleSmall?.copyWith(color: counts[m]! > 0 ? m.color : p.inkFaint)),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.moodFlow, style: context.text.titleLarge),
                const SizedBox(height: 4),
                Text(l.moodFlowHint, style: context.text.bodyMedium),
                const SizedBox(height: 16),
                SizedBox(
                  height: 180,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for (final m in [Mood.great, Mood.calm, Mood.meh, Mood.sad, Mood.angry]) MoodIcon(m, size: 22),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: CustomPaint(painter: _FlowPainter(flow, daysInMonth, p.accent, p.line, p.surface))),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [for (final d in [1, 8, 15, 22, daysInMonth]) Text('$d', style: context.text.labelSmall)],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _YearPixels(year: _month.year),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard();

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final l = context.l;
    final entries = context.watch<EntriesController>();
    final mondayFirst = context.watch<SettingsController>().weekStartsMonday(context.lang);
    final dates = Dates(context.lang);
    final today = dateOnly(DateTime.now());
    final offset = (today.weekday - (mondayFirst ? DateTime.monday : DateTime.sunday)) % 7;
    final weekStart = today.subtract(Duration(days: offset));
    final streak = entries.currentStreak;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color.lerp(p.accent, const Color(0xFFFFC56B), 0.35)!, p.accent],
        ),
        boxShadow: [BoxShadow(color: p.accent.withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.22), shape: BoxShape.circle),
                child: Image.asset('assets/moods/fluent/fire.webp', width: 36, height: 36),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.streakDays(streak), style: TextStyle(fontFamily: kDisplayFont, fontSize: 26, fontWeight: FontWeight.w600, color: p.onAccent)),
                    Text(
                      streak == 0 ? l.streakStart : l.longestStreak(entries.longestStreak),
                      style: TextStyle(color: p.onAccent.withValues(alpha: 0.85), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < 7; i++)
                Builder(builder: (_) {
                  final day = weekStart.add(Duration(days: i));
                  final done = entries.hasEntryOn(day);
                  final isToday = day == today;
                  return Column(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: done ? Colors.white : Colors.white.withValues(alpha: 0.18),
                          border: isToday ? Border.all(color: Colors.white, width: 2) : null,
                        ),
                        child: done ? Icon(PhBold.check, size: 18, color: p.accent) : null,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        dates.weekdayShort(day),
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: p.onAccent.withValues(alpha: isToday ? 1 : 0.8)),
                      ),
                    ],
                  );
                }),
            ],
          ),
        ],
      ),
    );
  }
}

class _Totals extends StatelessWidget {
  const _Totals({required this.entries});
  final EntriesController entries;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final items = [
      (PhFill.notebook, '${entries.entries.length}', l.statEntries, const Color(0xFFE5705F)),
      (PhFill.pencilSimple, '${entries.totalWords}', l.statWords, const Color(0xFF7C6BE0)),
      (PhFill.image, '${entries.photoCount}', l.statPhotos, const Color(0xFF2E9C86)),
      (PhFill.microphone, '${entries.voiceCount}', l.statVoice, const Color(0xFFE09A2C)),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.75,
      children: [
        for (final (icon, value, label, color) in items)
          SoftCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconBubble(icon, color: color, size: 34),
                const Spacer(),
                Text(value, style: context.text.headlineMedium),
                Text(label, style: context.text.bodySmall),
              ],
            ),
          ),
      ],
    );
  }
}

class _YearPixels extends StatelessWidget {
  const _YearPixels({required this.year});
  final int year;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final l = context.l;
    final entries = context.watch<EntriesController>();
    final dates = Dates(context.lang);
    final grid = List.generate(12, (m) {
      final days = DateTime(year, m + 2, 0).day;
      return List<Color?>.generate(31, (d) {
        if (d >= days) return null;
        final mood = entries.moodOn(DateTime(year, m + 1, d + 1));
        return mood?.color ?? (entries.hasEntryOn(DateTime(year, m + 1, d + 1)) ? p.accent.withValues(alpha: 0.5) : p.surface2);
      });
    });
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.yearInPixels(year), style: context.text.titleLarge),
          const SizedBox(height: 4),
          Text(l.yearInPixelsHint, style: context.text.bodyMedium),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var m = 0; m < 12; m++)
                Expanded(child: Center(child: Text(dates.monthShort(DateTime(year, m + 1)).characters.first, style: context.text.labelSmall))),
            ],
          ),
          const SizedBox(height: 6),
          AspectRatio(aspectRatio: 12 / 31 * 1.45, child: CustomPaint(painter: _PixelsPainter(grid))),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              for (final m in Mood.values)
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: m.color, borderRadius: BorderRadius.circular(3))),
                  const SizedBox(width: 5),
                  Text(m.label(l), style: context.text.labelSmall),
                ]),
            ],
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter(this.counts, this.track);
  final Map<Mood, int> counts;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.height * 0.16;
    final r = math.min(size.width / 2 - stroke / 2, size.height - stroke);
    final rect = Rect.fromCircle(center: Offset(size.width / 2, size.height - stroke / 2), radius: r);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, math.pi, math.pi, false, paint..color = track);
    final total = counts.values.fold(0, (a, b) => a + b);
    if (total == 0) return;
    // Round caps reach past an arc's ends, so each segment is inset by the cap angle.
    const gap = 0.06;
    final cap = stroke / 2 / r;
    final active = counts.entries.where((e) => e.value > 0).toList();
    final avail = math.pi - gap * (active.length - 1);
    var start = math.pi;
    for (final e in active) {
      final sweep = avail * e.value / total;
      final inner = math.max(0.0001, sweep - 2 * cap);
      final from = sweep > 2 * cap ? start + cap : start + sweep / 2;
      canvas.drawArc(rect, from, inner, false, paint..color = e.key.color);
      start += sweep + gap;
    }
  }

  @override
  bool shouldRepaint(_GaugePainter old) => true;
}

class _FlowPainter extends CustomPainter {
  _FlowPainter(this.points, this.days, this.accent, this.grid, this.surface);
  final List<(int, Mood)> points;
  final int days;
  final Color accent, grid, surface;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (var i = 0; i < 5; i++) {
      final y = 11 + (size.height - 22) * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    if (points.isEmpty) return;
    Offset pos((int, Mood) pt) => Offset(
          days <= 1 ? size.width / 2 : (pt.$1 - 1) / (days - 1) * size.width,
          11 + (size.height - 22) * (5 - pt.$2.valence) / 4,
        );
    final pts = points.map(pos).toList();
    if (pts.length > 1) {
      final path = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (var i = 1; i < pts.length; i++) {
        final a = pts[i - 1], b = pts[i];
        final mx = (a.dx + b.dx) / 2;
        path.cubicTo(mx, a.dy, mx, b.dy, b.dx, b.dy);
      }
      final fill = Path.from(path)
        ..lineTo(pts.last.dx, size.height)
        ..lineTo(pts.first.dx, size.height)
        ..close();
      canvas.drawPath(
        fill,
        Paint()..shader = ui.Gradient.linear(Offset.zero, Offset(0, size.height), [accent.withValues(alpha: 0.28), accent.withValues(alpha: 0)]),
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..color = accent,
      );
    }
    for (var i = 0; i < pts.length; i++) {
      canvas.drawCircle(pts[i], 6.5, Paint()..color = surface);
      canvas.drawCircle(pts[i], 4.5, Paint()..color = points[i].$2.color);
    }
  }

  @override
  bool shouldRepaint(_FlowPainter old) => true;
}

class _PixelsPainter extends CustomPainter {
  _PixelsPainter(this.grid);
  final List<List<Color?>> grid;

  @override
  void paint(Canvas canvas, Size size) {
    final cw = size.width / 12;
    final ch = size.height / 31;
    final paint = Paint();
    for (var m = 0; m < 12; m++) {
      for (var d = 0; d < 31; d++) {
        final c = grid[m][d];
        if (c == null) continue;
        paint.color = c;
        final r = Rect.fromLTWH(m * cw + cw * 0.12, d * ch + ch * 0.1, cw * 0.76, ch * 0.8);
        canvas.drawRRect(RRect.fromRectAndRadius(r, Radius.circular(math.min(r.width, r.height) * 0.3)), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_PixelsPainter old) => true;
}
