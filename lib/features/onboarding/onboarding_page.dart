import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_config.dart';
import '../../core/palette.dart';
import '../../core/scene.dart';
import '../../core/themes.dart';
import '../../core/widgets.dart';
import '../../data/mood.dart';
import '../../data/settings.dart';
import '../../services/ads_service.dart';
import '../../services/pro_service.dart';
import '../more/reminders.dart';
import '../more/theme_picker_page.dart';
import '../paywall/paywall_page.dart';

/// First run: welcome & language → privacy → style → reminder → (Premium offer).
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pages = PageController();
  int _step = 0;

  void _next() {
    final pro = context.read<ProController>();
    final last = pro.storeReady ? 4 : 3;
    if (_step >= last) {
      _finish();
      return;
    }
    setState(() => _step++);
    _pages.animateToPage(_step, duration: const Duration(milliseconds: 520), curve: Curves.easeInOutCubic);
  }

  Future<void> _finish() async {
    await context.read<SettingsController>().setOnboarded(true);
    AdsService.instance.start();
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storeReady = context.watch<ProController>().storeReady;
    return Scaffold(
      body: PageView(
        controller: _pages,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _Welcome(onNext: _next),
          _Privacy(onNext: _next),
          _Style(onNext: _next),
          _Reminder(onNext: _next),
          if (storeReady) PaywallPage(onDone: _finish),
        ],
      ),
    );
  }
}

class _Welcome extends StatelessWidget {
  const _Welcome({required this.onNext});
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final l = context.l;
    final settings = context.watch<SettingsController>();
    final lang = context.lang;
    final linkStyle = TextStyle(color: p.accent, fontWeight: FontWeight.w800);
    return Column(
      children: [
        Expanded(
          flex: 11,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(44)),
            child: Stack(
              children: [
                Positioned.fill(child: SceneView(spec: AppThemes.byId('dawn').scene)),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 26,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Floating(child: MoodIcon(Mood.calm, size: 78)),
                      const SizedBox(width: 6),
                      Padding(padding: const EdgeInsets.only(bottom: 18), child: Floating(child: MoodIcon(Mood.great, size: 104))),
                      const SizedBox(width: 6),
                      Floating(child: MoodIcon(Mood.loved, size: 78)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 10,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 26, 28, 14),
              child: Column(
                children: [
                  Text(l.appTitle, style: context.text.displayLarge),
                  const SizedBox(height: 8),
                  Text(l.tagline, textAlign: TextAlign.center, style: context.text.bodyLarge?.copyWith(color: p.inkSoft)),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: p.surface2, borderRadius: BorderRadius.circular(22)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final (code, name) in const [('tr', 'Türkçe'), ('en', 'English')])
                          Pressable(
                            onTap: () => settings.setLanguage(code),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                              decoration: BoxDecoration(
                                color: lang == code ? p.surface : Colors.transparent,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: lang == code ? p.softShadow : null,
                              ),
                              child: Text(name, style: context.text.labelLarge?.copyWith(color: lang == code ? p.ink : p.inkFaint)),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  AppButton(label: l.getStarted, onTap: onNext),
                  const SizedBox(height: 12),
                  Text.rich(
                    TextSpan(
                      style: context.text.bodySmall,
                      children: [
                        TextSpan(text: l.termsLead),
                        TextSpan(text: l.terms, style: linkStyle, recognizer: TapGestureRecognizer()..onTap = () => launchUrl(Uri.parse(AppConfig.termsUrl))),
                        TextSpan(text: l.termsAnd),
                        TextSpan(text: l.privacyPolicy, style: linkStyle, recognizer: TapGestureRecognizer()..onTap = () => launchUrl(Uri.parse(AppConfig.privacyPolicyUrl))),
                        TextSpan(text: l.termsTail),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StepFrame extends StatelessWidget {
  const _StepFrame({required this.step, required this.child});
  final int step;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 1; i <= 3; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == step ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(color: i == step ? p.accent : p.line, borderRadius: BorderRadius.circular(4)),
                ),
            ],
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _Privacy extends StatelessWidget {
  const _Privacy({required this.onNext});
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final settings = context.read<SettingsController>();
    final points = [
      (PhFill.lockKey, l.privacyPoint1),
      (PhFill.fingerprint, l.privacyPoint2),
      (PhFill.megaphone, l.privacyPoint3),
    ];
    return _StepFrame(
      step: 1,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),
            IconBubble(PhFill.shieldCheck, size: 84),
            const SizedBox(height: 22),
            Text(l.privacyTitle, style: context.text.displaySmall),
            const SizedBox(height: 18),
            for (final (icon, text) in points)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: context.pal.accent, size: 22),
                    const SizedBox(width: 14),
                    Expanded(child: Text(text, style: context.text.bodyLarge?.copyWith(color: context.pal.inkSoft, height: 1.45))),
                  ],
                ),
              ),
            const Spacer(),
            AppButton(
              label: l.acceptPersonalized,
              onTap: () async {
                await settings.setAdsPersonalized(true);
                onNext();
              },
            ),
            const SizedBox(height: 6),
            AppButton(
              label: l.declinePersonalized,
              kind: ButtonKind.ghost,
              onTap: () async {
                await settings.setAdsPersonalized(false);
                onNext();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Style extends StatefulWidget {
  const _Style({required this.onNext});
  final VoidCallback onNext;

  @override
  State<_Style> createState() => _StyleState();
}

class _StyleState extends State<_Style> {
  late final PageController _cards;
  late int _index;

  @override
  void initState() {
    super.initState();
    final current = context.read<SettingsController>().themeId;
    _index = AppThemes.all.indexWhere((t) => t.id == current).clamp(0, AppThemes.all.length - 1);
    _cards = PageController(viewportFraction: 0.68, initialPage: _index);
  }

  @override
  void dispose() {
    _cards.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final isPro = context.watch<ProController>().isPro;
    final theme = AppThemes.all[_index];
    final locked = theme.isPro && !isPro;
    final tp = theme.palette;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      color: tp.bg,
      child: Theme(
        data: buildTheme(tp),
        child: Builder(builder: (context) {
          return _StepFrame(
            step: 2,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 24, 28, 4),
                  child: Text(l.findYourStyle, style: context.text.displaySmall, textAlign: TextAlign.center),
                ),
                Text(l.findYourStyleHint, style: context.text.bodyMedium, textAlign: TextAlign.center),
                Expanded(
                  child: PageView.builder(
                    controller: _cards,
                    itemCount: AppThemes.all.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (_, i) {
                      final t = AppThemes.all[i];
                      return AnimatedPadding(
                        duration: const Duration(milliseconds: 300),
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: i == _index ? 20 : 44),
                        child: ThemeCard(
                          theme: t,
                          selected: i == _index,
                          locked: t.isPro && !isPro,
                          animate: i == _index,
                          onTap: () => _cards.animateToPage(i, duration: const Duration(milliseconds: 380), curve: Curves.easeOutCubic),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 16),
                  child: AppButton(
                    label: locked ? l.unlockWithPremium : l.continueLabel,
                    icon: locked ? PhFill.crownSimple : null,
                    onTap: () async {
                      if (locked && !await ensurePro(context)) return;
                      if (!context.mounted) return;
                      await context.read<SettingsController>().setThemeId(theme.id);
                      widget.onNext();
                    },
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _Reminder extends StatefulWidget {
  const _Reminder({required this.onNext});
  final VoidCallback onNext;

  @override
  State<_Reminder> createState() => _ReminderState();
}

class _ReminderState extends State<_Reminder> {
  late TimeOfDay _time = context.read<SettingsController>().reminderTime;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final l = context.l;
    return _StepFrame(
      step: 3,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 16),
        child: Column(
          children: [
            const Spacer(),
            Floating(child: IconBubble(PhFill.bellRinging, size: 96)),
            const SizedBox(height: 26),
            Text(l.reminderOnboardTitle, style: context.text.displaySmall, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text(l.reminderOnboardText, style: context.text.bodyLarge?.copyWith(color: p.inkSoft), textAlign: TextAlign.center),
            const SizedBox(height: 26),
            Pressable(
              onTap: () async {
                final t = await showTimePicker(context: context, initialTime: _time, helpText: l.reminderTime);
                if (t != null) setState(() => _time = t);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(22), boxShadow: p.softShadow),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Ph.alarm, color: p.accent),
                    const SizedBox(width: 10),
                    Text(_time.format(context), style: TextStyle(fontFamily: kDisplayFont, fontSize: 28, fontWeight: FontWeight.w600, color: p.ink)),
                    const SizedBox(width: 10),
                    Text(l.change, style: TextStyle(color: p.accent, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ),
            const Spacer(),
            AppButton(
              label: l.remindMe,
              icon: PhFill.bell,
              onTap: () async {
                await context.read<SettingsController>().setReminder(on: false, time: _time);
                if (!context.mounted) return;
                await enableReminder(context, pickTime: false);
                widget.onNext();
              },
            ),
            const SizedBox(height: 6),
            AppButton(label: l.notNow, kind: ButtonKind.ghost, onTap: widget.onNext),
          ],
        ),
      ),
    );
  }
}
