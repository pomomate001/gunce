import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/format.dart';
import '../../core/scene.dart';
import '../../core/themes.dart';
import '../../core/widgets.dart';
import '../../data/entries_controller.dart';
import '../../data/entry.dart';
import '../../data/mood.dart';
import '../../data/settings.dart';
import '../../services/pro_service.dart';
import '../editor/editor_page.dart';
import '../more/theme_picker_page.dart';
import '../paywall/paywall_page.dart';
import '../search/search_page.dart';
import 'entry_card.dart';

String dailyPrompt(BuildContext context, [DateTime? day]) {
  final prompts = context.l.writingPrompts.split('|');
  final d = day ?? DateTime.now();
  final index = DateTime(d.year, d.month, d.day).difference(DateTime(2024)).inDays;
  return prompts[index % prompts.length];
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = context.watch<EntriesController>().entries;
    final dates = Dates(context.lang);

    // Flat list of month headers and entries.
    final items = <Object>[];
    String? month;
    for (final e in entries) {
      final m = dates.monthYear(e.date);
      if (m != month) {
        items.add(m);
        month = m;
      }
      items.add(e);
    }

    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: _Header()),
        const SliverToBoxAdapter(child: _TodayCard()),
        if (entries.isEmpty)
          SliverToBoxAdapter(
            child: EmptyState(
              title: context.l.emptyJournalTitle,
              message: context.l.emptyJournalMessage,
              mood: Mood.happy,
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList.builder(
              itemCount: items.length,
              itemBuilder: (context, i) {
                final item = items[i];
                if (item is String) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(6, 22, 6, 10),
                    child: Text(item, style: context.text.titleLarge?.copyWith(color: context.pal.inkSoft)),
                  );
                }
                final e = item as Entry;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: EnterAnimation(index: i, child: EntryCard(key: ValueKey(e.id), entry: e)),
                );
              },
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 130)),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final l = context.l;
    final isPro = context.watch<ProController>().isPro;
    final theme = AppThemes.byId(context.watch<SettingsController>().themeId);
    final spec = theme.isPro && !isPro ? AppThemes.byId(null) : theme;
    final now = DateTime.now();
    final greeting = switch (now.hour) {
      >= 5 && < 12 => l.goodMorning,
      >= 12 && < 18 => l.goodAfternoon,
      >= 18 && < 23 => l.goodEvening,
      _ => l.goodNight,
    };

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 10, 12, 12),
            child: Row(
              children: [
                Expanded(child: Text(l.appTitle, style: context.text.displaySmall)),
                if (!isPro)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Pressable(
                      onTap: () => ensurePro(context),
                      semanticLabel: l.premiumTitle,
                      child: const ProBadge(size: 40),
                    ),
                  ),
                CircleButton(
                  icon: Ph.magnifyingGlass,
                  background: p.surface,
                  tooltip: l.search,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SearchPage())),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 196,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), boxShadow: p.softShadow),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Stack(
                  children: [
                    Positioned.fill(child: SceneView(spec: spec.scene)),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.32)],
                            stops: const [0.45, 1],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      bottom: 16,
                      right: 70,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(greeting, style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w700, shadows: [Shadow(blurRadius: 8, color: Colors.black26)])),
                          Text(
                            Dates(context.lang).dayMonth(now),
                            style: const TextStyle(fontFamily: 'Fraunces', fontSize: 27, fontWeight: FontWeight.w600, color: Colors.white, shadows: [Shadow(blurRadius: 10, color: Colors.black26)]),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: CircleButton(
                        icon: PhFill.palette,
                        size: 42,
                        color: p.accent,
                        background: Colors.white.withValues(alpha: 0.9),
                        tooltip: l.chooseTheme,
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ThemePickerPage())),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "How are you today?" quick check-in, or the streak once today is written.
class _TodayCard extends StatelessWidget {
  const _TodayCard();

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final l = context.l;
    final entries = context.watch<EntriesController>();
    final today = DateTime.now();
    final written = entries.hasEntryOn(today);
    final streak = entries.currentStreak;
    final prompt = dailyPrompt(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: SoftCard(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
        child: written
            ? Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: const Color(0xFFFF8A3D).withValues(alpha: 0.14), shape: BoxShape.circle),
                    child: Image.asset('assets/moods/fluent/fire.webp', width: 32, height: 32),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.streakDays(streak), style: context.text.headlineSmall),
                        const SizedBox(height: 2),
                        Text(l.todayWritten, style: context.text.bodyMedium),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.howAreYouToday, style: context.text.headlineSmall),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (final m in Mood.values)
                        Pressable(
                          scale: 0.82,
                          onTap: () => openEditor(context, mood: m, prompt: prompt),
                          semanticLabel: m.label(l),
                          child: MoodIcon(m, size: 36),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(color: p.line),
                  Pressable(
                    onTap: () => openEditor(context, prompt: prompt),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        children: [
                          Icon(PhFill.quotes, color: p.accent, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              prompt,
                              style: TextStyle(fontFamily: 'Fraunces', fontStyle: FontStyle.italic, fontSize: 15.5, color: p.inkSoft, height: 1.35),
                            ),
                          ),
                          Icon(Ph.caretRight, color: p.inkFaint, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
