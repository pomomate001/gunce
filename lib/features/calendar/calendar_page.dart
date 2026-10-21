import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/format.dart';
import '../../core/palette.dart';
import '../../core/widgets.dart';
import '../../data/entries_controller.dart';
import '../../data/mood.dart';
import '../../data/settings.dart';
import '../editor/editor_page.dart';
import '../home/entry_card.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _month;
  late DateTime _selected;
  int _direction = 1;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    _selected = dateOnly(now);
  }

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return _month.year == now.year && _month.month == now.month;
  }

  void _shift(int months) {
    if (months > 0 && _isCurrentMonth) return;
    setState(() {
      _direction = months;
      _month = DateTime(_month.year, _month.month + months);
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final l = context.l;
    final entries = context.watch<EntriesController>();
    final settings = context.watch<SettingsController>();
    final dates = Dates(context.lang);
    final mondayFirst = settings.weekStartsMonday(context.lang);
    final dayEntries = entries.forDay(_selected);
    final today = dateOnly(DateTime.now());

    // Weekday headers starting from the configured first day.
    final firstWeekday = mondayFirst ? DateTime.monday : DateTime.sunday;
    final headerDays = [for (var i = 0; i < 7; i++) DateTime(2024, 1, 1 + (firstWeekday - 1 + i) % 7)]; // 2024-01-01 is a Monday

    final first = DateTime(_month.year, _month.month);
    final lead = (first.weekday - firstWeekday) % 7;
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final cells = lead + daysInMonth;
    final monthEntries = entries.inRange(first, DateTime(_month.year, _month.month + 1));

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 130),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 10, 12, 6),
            child: Row(
              children: [
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    layoutBuilder: (current, previous) => Stack(alignment: Alignment.centerLeft, children: [...previous, ?current]),
                    child: Text(dates.monthYear(_month), key: ValueKey(_month), style: context.text.displaySmall),
                  ),
                ),
                CircleButton(icon: Ph.caretLeft, onTap: () => _shift(-1), background: p.surface, tooltip: l.previous),
                const SizedBox(width: 8),
                Opacity(
                  opacity: _isCurrentMonth ? 0.35 : 1,
                  child: CircleButton(icon: Ph.caretRight, onTap: () => _shift(1), background: p.surface, tooltip: l.next),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 4),
            child: Text(l.entriesThisMonth(monthEntries.length), style: context.text.bodyMedium),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: SoftCard(
              padding: const EdgeInsets.fromLTRB(8, 14, 8, 10),
              child: GestureDetector(
                onHorizontalDragEnd: (d) {
                  final v = d.primaryVelocity ?? 0;
                  if (v.abs() > 200) _shift(v < 0 ? 1 : -1);
                },
                child: Column(
                  children: [
                    Row(
                      children: [
                        for (final d in headerDays)
                          Expanded(child: Center(child: Text(dates.weekdayShort(d), style: context.text.labelSmall))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      transitionBuilder: (child, anim) {
                        final incoming = child.key == ValueKey(_month);
                        final dx = (incoming ? 0.25 : -0.25) * _direction;
                        return FadeTransition(
                          opacity: anim,
                          child: SlideTransition(position: Tween(begin: Offset(dx, 0), end: Offset.zero).animate(anim), child: child),
                        );
                      },
                      child: GridView.builder(
                        key: ValueKey(_month),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 0.8),
                        itemCount: (cells / 7).ceil() * 7,
                        itemBuilder: (_, i) {
                          final dayNum = i - lead + 1;
                          if (dayNum < 1 || dayNum > daysInMonth) return const SizedBox.shrink();
                          final day = DateTime(_month.year, _month.month, dayNum);
                          return _DayCell(
                            day: day,
                            mood: entries.moodOn(day),
                            hasEntry: entries.hasEntryOn(day),
                            isToday: day == today,
                            isSelected: day == _selected,
                            isFuture: day.isAfter(today),
                            onTap: () => setState(() => _selected = day),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 10),
            child: Text(dates.full(_selected), style: context.text.titleLarge),
          ),
          if (dayEntries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SoftCard(
                child: Row(
                  children: [
                    Expanded(child: Text(_selected.isAfter(today) ? l.futureDay : l.noEntryThisDay, style: context.text.bodyMedium)),
                    if (!_selected.isAfter(today))
                      AppButton(label: l.write, icon: Ph.pencilSimple, expand: false, height: 44, onTap: () => openEditor(context, date: _selected)),
                  ],
                ),
              ),
            )
          else
            for (final e in dayEntries)
              Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 12), child: EntryCard(key: ValueKey(e.id), entry: e)),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.mood,
    required this.hasEntry,
    required this.isToday,
    required this.isSelected,
    required this.isFuture,
    required this.onTap,
  });

  final DateTime day;
  final Mood? mood;
  final bool hasEntry, isToday, isSelected, isFuture;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final numberStyle = TextStyle(
      fontFamily: kBodyFont,
      fontSize: 13,
      fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
      color: isToday ? p.accent : (isFuture ? p.inkFaint.withValues(alpha: 0.5) : p.inkSoft),
    );
    return Pressable(
      onTap: isFuture ? null : onTap,
      scale: 0.88,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected ? p.accentSoft : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isToday && !isSelected ? Border.all(color: p.accent.withValues(alpha: 0.5), width: 1.4) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (mood != null)
              MoodIcon(mood, size: 30)
            else
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hasEntry ? p.accent.withValues(alpha: 0.18) : (isFuture ? Colors.transparent : p.surface2),
                ),
                child: hasEntry ? Icon(PhFill.notePencil, size: 15, color: p.accent) : null,
              ),
            const SizedBox(height: 3),
            Text('${day.day}', style: numberStyle),
          ],
        ),
      ),
    );
  }
}
