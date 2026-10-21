import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/palette.dart';
import '../../core/scene.dart';
import '../../core/themes.dart';
import '../../core/widgets.dart';
import '../../data/settings.dart';
import '../../services/pro_service.dart';
import '../paywall/paywall_page.dart';

class ThemePickerPage extends StatelessWidget {
  const ThemePickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final isPro = context.watch<ProController>().isPro;
    return Scaffold(
      appBar: AppBar(
        leading: CircleButton(icon: Ph.arrowLeft, onTap: () => Navigator.pop(context), background: Colors.transparent),
        title: Text(context.l.chooseTheme),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 14, childAspectRatio: 0.74),
        itemCount: AppThemes.all.length,
        itemBuilder: (context, i) {
          final t = AppThemes.all[i];
          return EnterAnimation(
            index: i,
            child: ThemeCard(
              theme: t,
              selected: settings.themeId == t.id,
              locked: t.isPro && !isPro,
              onTap: () async {
                if (t.isPro && !isPro && !await ensurePro(context)) return;
                await settings.setThemeId(t.id);
              },
            ),
          );
        },
      ),
    );
  }
}

/// Miniature of a theme: its landscape plus a hint of its colours.
class ThemeCard extends StatelessWidget {
  const ThemeCard({super.key, required this.theme, required this.selected, required this.locked, required this.onTap, this.animate = false});

  final AppThemeSpec theme;
  final bool selected, locked, animate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final tp = theme.palette;
    return Pressable(
      onTap: onTap,
      child: Column(
        children: [
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: tp.bg,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: selected ? p.accent : p.line, width: selected ? 2.6 : 1),
                boxShadow: selected ? [BoxShadow(color: p.accent.withValues(alpha: 0.3), blurRadius: 18, offset: const Offset(0, 6))] : p.softShadow,
              ),
              child: Column(
                children: [
                  Expanded(
                    flex: 5,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(borderRadius: BorderRadius.circular(20), child: SceneView(spec: theme.scene, animate: animate || selected)),
                        ),
                        if (locked) const Positioned(right: 8, top: 8, child: ProBadge(size: 24)),
                        if (selected)
                          Positioned(
                            left: 8,
                            top: 8,
                            child: Container(
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: Icon(PhFill.checkCircle, color: p.accent, size: 26),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(6, 10, 6, 4),
                      // Large cards (onboarding) get a miniature of the app; grid cards a hint.
                      child: LayoutBuilder(builder: (context, box) => box.maxHeight > 110 ? _MiniApp(tp) : _MiniHint(tp)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(theme.name(context.l), style: context.text.titleSmall),
        ],
      ),
    );
  }
}

Widget _bar(Color c, double w, [double h = 6]) =>
    Container(height: h, width: w, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(h / 2)));

class _MiniHint extends StatelessWidget {
  const _MiniHint(this.tp);
  final AppPalette tp;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [_bar(tp.ink.withValues(alpha: 0.75), 70, 7), const SizedBox(height: 6), _bar(tp.inkFaint.withValues(alpha: 0.6), 46)],
          ),
        ),
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(color: tp.accent, shape: BoxShape.circle),
          child: Icon(PhBold.plus, size: 14, color: tp.onAccent),
        ),
      ],
    );
  }
}

class _MiniApp extends StatelessWidget {
  const _MiniApp(this.tp);
  final AppPalette tp;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: tp.surface, borderRadius: BorderRadius.circular(16), boxShadow: tp.softShadow),
          child: Row(
            children: [
              Text('${now.day}', style: TextStyle(fontFamily: kDisplayFont, fontSize: 24, fontWeight: FontWeight.w600, color: tp.ink)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _bar(tp.ink.withValues(alpha: 0.75), 90, 7),
                    const SizedBox(height: 6),
                    _bar(tp.inkFaint.withValues(alpha: 0.55), 120),
                    const SizedBox(height: 5),
                    _bar(tp.inkFaint.withValues(alpha: 0.4), 70),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(PhFill.notebook, size: 20, color: tp.accent),
            Icon(Ph.calendarBlank, size: 20, color: tp.inkFaint),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(color: tp.accent, shape: BoxShape.circle),
              child: Icon(PhBold.plus, size: 16, color: tp.onAccent),
            ),
            Icon(Ph.chartPieSlice, size: 20, color: tp.inkFaint),
            Icon(Ph.dotsThreeOutline, size: 20, color: tp.inkFaint),
          ],
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}
