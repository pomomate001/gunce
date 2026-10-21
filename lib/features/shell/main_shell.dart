import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets.dart';
import '../../data/settings.dart';
import '../../services/ads_service.dart';
import '../calendar/calendar_page.dart';
import '../editor/editor_page.dart';
import '../home/home_page.dart';
import '../more/more_page.dart';
import '../more/reminders.dart';
import '../stats/stats_page.dart';

/// Bottom navigation (Journal, Calendar, +, Insights, More) and the single banner slot.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with SingleTickerProviderStateMixin {
  int _index = 0;
  late final _fade = AnimationController(vsync: this, duration: const Duration(milliseconds: 260), value: 1);

  static const _pages = [HomePage(), CalendarPage(), StatsPage(), MorePage()];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && context.read<SettingsController>().reminderOn) syncReminders(context);
    });
  }

  void _go(int i) {
    if (i == _index) return;
    setState(() => _index = i);
    _fade.forward(from: 0);
    AdsService.instance.onNaturalBreak();
  }

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final l = context.l;
    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _go(0);
      },
      child: Scaffold(
        extendBody: true,
        body: ValueListenableBuilder<bool>(
          valueListenable: AdsService.instance.bannersOn,
          builder: (context, adsOn, _) => Column(
          children: [
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeBottom: adsOn,
                child: Stack(
                children: [
                  FadeTransition(
                    opacity: CurvedAnimation(parent: _fade, curve: Curves.easeOut),
                    child: IndexedStack(
                      index: _index,
                      children: [
                        for (var i = 0; i < _pages.length; i++) TickerMode(enabled: i == _index, child: _pages[i]),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 12,
                    child: SafeArea(
                      top: false,
                      child: _NavBar(
                        index: _index,
                        onTap: _go,
                        onAdd: () => openEditor(context),
                        items: [
                          (Ph.notebook, PhFill.notebook, l.navJournal),
                          (Ph.calendarBlank, PhFill.calendarBlank, l.navCalendar),
                          (Ph.chartPieSlice, PhFill.chartPieSlice, l.navInsights),
                          (Ph.dotsThreeOutline, PhFill.dotsThreeOutline, l.navMore),
                        ],
                      ),
                    ),
                  ),
                ],
                ),
              ),
            ),
            if (adsOn) ColoredBox(color: p.bg, child: const SafeArea(top: false, child: Center(child: AdBanner()))),
          ],
          ),
        ),
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  const _NavBar({required this.index, required this.onTap, required this.onAdd, required this.items});

  final int index;
  final ValueChanged<int> onTap;
  final VoidCallback onAdd;
  final List<(IconData, IconData, String)> items;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    Widget item(int i) {
      final (icon, active, label) = items[i];
      final sel = i == index;
      return Expanded(
        child: Pressable(
          onTap: () => onTap(i),
          scale: 0.9,
          semanticLabel: label,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                child: Icon(sel ? active : icon, key: ValueKey(sel), size: 25, color: sel ? p.accent : p.inkFaint),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, fontWeight: sel ? FontWeight.w800 : FontWeight.w700, color: sel ? p.accent : p.inkFaint),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 84,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: 70,
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [BoxShadow(color: p.shadow.withValues(alpha: p.shadow.a * 1.7), blurRadius: 32, offset: const Offset(0, 12))],
              border: p.isDark ? Border.all(color: p.line) : null,
            ),
            child: Row(children: [item(0), item(1), const SizedBox(width: 76), item(2), item(3)]),
          ),
          Positioned(
            top: 0,
            child: Pressable(
              onTap: onAdd,
              scale: 0.9,
              semanticLabel: context.l.newEntry,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color.lerp(p.accent, Colors.white, 0.18)!, p.accent],
                  ),
                  border: Border.all(color: p.surface, width: 4),
                  boxShadow: [BoxShadow(color: p.accent.withValues(alpha: 0.4), blurRadius: 18, offset: const Offset(0, 8))],
                ),
                child: Icon(PhBold.plus, color: p.onAccent, size: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
