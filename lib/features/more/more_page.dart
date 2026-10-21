import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_config.dart';
import '../../core/themes.dart';
import '../../core/widgets.dart';
import '../../data/entries_controller.dart';
import '../../data/settings.dart';
import '../../services/ads_service.dart';
import '../../services/backup_service.dart';
import '../../services/lock_service.dart';
import '../../services/notification_service.dart';
import '../../services/pro_service.dart';
import '../lock/lock_gate.dart';
import '../lock/pin_setup_page.dart';
import '../paywall/paywall_page.dart';
import 'mood_pack_page.dart';
import 'reminders.dart';
import 'theme_picker_page.dart';

class MorePage extends StatefulWidget {
  const MorePage({super.key});

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  bool _bioAvailable = false;
  String _version = '';
  int _versionTaps = 0;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    LockService.biometricAvailable().then((v) => mounted ? setState(() => _bioAvailable = v) : null);
    PackageInfo.fromPlatform().then((i) => mounted ? setState(() => _version = i.version) : null);
  }

  void _push(Widget page) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  Future<void> _togglePin(SettingsController s) async {
    final l = context.l;
    if (s.hasPin) {
      final ok = await confirm(context, title: l.removePinTitle, message: l.removePinMessage, confirmLabel: l.remove, destructive: true);
      if (ok) await s.setPin(null, null);
    } else {
      final created = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => const PinSetupPage()));
      if (created == true && mounted) toast(context, l.pinSet, icon: PhFill.lockKey);
    }
  }

  Future<void> _toggleReminder(SettingsController s) async {
    if (s.reminderOn) {
      await s.setReminder(on: false);
      await NotificationService.instance.cancelDaily();
    } else {
      await enableReminder(context);
    }
  }

  Future<void> _changeReminderTime(SettingsController s) async {
    if (!s.reminderOn) return _toggleReminder(s);
    final picked = await showTimePicker(context: context, initialTime: s.reminderTime, helpText: context.l.reminderTime);
    if (picked == null || !mounted) return;
    await s.setReminder(on: true, time: picked);
    if (mounted) await syncReminders(context);
  }

  Future<void> _pickLanguage(SettingsController s) async {
    final current = context.lang;
    final code = await showAppSheet<String>(
      context,
      (ctx) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SheetHeader(title: ctx.l.language),
            for (final (c, name) in const [('tr', 'Türkçe'), ('en', 'English')])
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                title: Text(name, style: ctx.text.titleMedium),
                trailing: c == current ? Icon(PhFill.checkCircle, color: ctx.pal.accent) : null,
                onTap: () => Navigator.pop(ctx, c),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
    if (code == null || code == current) return;
    await s.setLanguage(code);
    // Notifications carry text, so reschedule them in the new language.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) syncReminders(context);
    });
  }

  Future<void> _export() async {
    setState(() => _busy = true);
    LockGate.allowBackground(const Duration(minutes: 5));
    try {
      await BackupService.export(context.read<EntriesController>(), shareText: context.l.backupShareText);
    } catch (e) {
      if (mounted) toast(context, context.l.backupFailed);
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _import() async {
    final l = context.l;
    LockGate.allowBackground(const Duration(minutes: 5));
    try {
      final n = await BackupService.import(context.read<EntriesController>());
      if (n != null && mounted) toast(context, l.restoreDone(n), icon: PhFill.checkCircle);
    } catch (e) {
      if (mounted) toast(context, l.restoreFailed);
    }
  }

  void _onVersionTap() {
    if (!kDevTools) return;
    if (++_versionTaps % 7 == 0) {
      context.read<ProController>().toggleDevPro();
      toast(context, 'Dev: Pro ${context.read<ProController>().isPro ? 'ON' : 'OFF'}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final s = context.watch<SettingsController>();
    final isPro = context.watch<ProController>().isPro;
    final theme = AppThemes.byId(s.themeId);
    final lang = context.lang;
    final ads = AdsService.instance;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 130),
        children: [
          Padding(padding: const EdgeInsets.fromLTRB(6, 0, 0, 16), child: Text(l.moreTitle, style: context.text.displaySmall)),
          _PremiumCard(isPro: isPro),
          _Section(l.sectionPersonalize, [
            _Tile(icon: PhFill.palette, color: const Color(0xFFE5705F), title: l.appTheme, value: theme.name(l), onTap: () => _push(const ThemePickerPage())),
            _Tile(icon: PhFill.smiley, color: const Color(0xFFE0A21C), title: l.emojiPack, value: s.moodPack.name(l), onTap: () => _push(const MoodPackPage())),
          ]),
          _Section(l.sectionHabit, [
            _Tile(
              icon: PhFill.bellRinging,
              color: const Color(0xFF7C6BE0),
              title: l.dailyReminder,
              subtitle: s.reminderOn ? l.reminderAt(s.reminderTime.format(context)) : l.off,
              onTap: () => _changeReminderTime(s),
              trailing: Switch(value: s.reminderOn, onChanged: (_) => _toggleReminder(s)),
            ),
          ]),
          _Section(l.sectionSecurity, [
            _Tile(
              icon: PhFill.lockKey,
              color: const Color(0xFF2E9C86),
              title: l.pinLock,
              subtitle: s.hasPin ? l.on : l.off,
              onTap: () => _togglePin(s),
              trailing: Switch(value: s.hasPin, onChanged: (_) => _togglePin(s)),
            ),
            if (s.hasPin && _bioAvailable)
              _Tile(
                icon: PhFill.fingerprint,
                color: const Color(0xFF2E9C86),
                title: l.biometricUnlock,
                onTap: () => s.setBiometric(!s.biometric),
                trailing: Switch(value: s.biometric, onChanged: (v) => s.setBiometric(v)),
              ),
            if (!isPro)
              _Tile(
                icon: PhFill.shieldCheck,
                color: const Color(0xFF4A7BD3),
                title: l.personalizedAds,
                subtitle: l.personalizedAdsHint,
                onTap: () => s.setAdsPersonalized(!s.adsPersonalized),
                trailing: Switch(value: s.adsPersonalized, onChanged: (v) => s.setAdsPersonalized(v)),
              ),
            if (!isPro && ads.privacyOptionsRequired)
              _Tile(icon: PhFill.sliders, color: const Color(0xFF4A7BD3), title: l.adPrivacyOptions, onTap: ads.showPrivacyOptions),
          ]),
          _Section(l.sectionGeneral, [
            _Tile(icon: PhFill.globe, color: const Color(0xFF1F7EA1), title: l.language, value: lang == 'tr' ? 'Türkçe' : 'English', onTap: () => _pickLanguage(s)),
            _Tile(
              icon: PhFill.calendarDots,
              color: const Color(0xFF1F7EA1),
              title: l.weekStart,
              value: s.weekStartsMonday(lang) ? l.monday : l.sunday,
              onTap: () => s.setWeekStartsMonday(!s.weekStartsMonday(lang)),
            ),
          ]),
          _Section(l.sectionData, [
            _Tile(icon: PhFill.uploadSimple, color: const Color(0xFFC95F2C), title: l.createBackup, subtitle: l.createBackupHint, onTap: _busy ? null : _export),
            _Tile(icon: PhFill.downloadSimple, color: const Color(0xFFC95F2C), title: l.restoreBackup, onTap: _import),
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 10, 8, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(PhFill.shieldCheck, size: 18, color: context.pal.inkFaint),
                const SizedBox(width: 8),
                Expanded(child: Text(l.localOnlyNote, style: context.text.bodySmall?.copyWith(fontWeight: FontWeight.w600, height: 1.4))),
              ],
            ),
          ),
          _Section(l.sectionSupport, [
            _Tile(icon: PhFill.heart, color: const Color(0xFFDF5A86), title: l.rateApp, onTap: () => launchUrl(Uri.parse(AppConfig.playStoreUrl), mode: LaunchMode.externalApplication)),
            _Tile(
              icon: PhFill.shareNetwork,
              color: const Color(0xFFDF5A86),
              title: l.shareApp,
              onTap: () => SharePlus.instance.share(ShareParams(text: l.shareAppText(AppConfig.playStoreUrl))),
            ),
            _Tile(icon: PhFill.fileText, color: const Color(0xFF8A8FA8), title: l.privacyPolicy, onTap: () => launchUrl(Uri.parse(AppConfig.privacyPolicyUrl))),
            _Tile(
              icon: PhFill.info,
              color: const Color(0xFF8A8FA8),
              title: l.licenses,
              onTap: () => showLicensePage(context: context, applicationName: AppConfig.appName, applicationVersion: _version),
            ),
          ]),
          const SizedBox(height: 22),
          GestureDetector(
            onTap: _onVersionTap,
            child: Center(child: Text('${AppConfig.appName} $_version', style: context.text.bodySmall)),
          ),
          const SizedBox(height: 4),
          Center(child: Text(l.madeWithLove, style: context.text.bodySmall)),
        ],
      ),
    );
  }
}

class _PremiumCard extends StatelessWidget {
  const _PremiumCard({required this.isPro});
  final bool isPro;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Pressable(
      onTap: isPro ? null : () => ensurePro(context),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: const LinearGradient(colors: [Color(0xFF2B2758), Color(0xFF8E4A7E), Color(0xFFF2836B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          boxShadow: [BoxShadow(color: const Color(0xFF8E4A7E).withValues(alpha: 0.3), blurRadius: 22, offset: const Offset(0, 10))],
        ),
        child: Row(
          children: [
            const ProBadge(size: 48),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isPro ? l.premiumActive : l.premiumTitle, style: const TextStyle(fontFamily: 'Fraunces', fontSize: 21, fontWeight: FontWeight.w600, color: Colors.white)),
                  const SizedBox(height: 3),
                  Text(isPro ? l.premiumThanks : l.premiumPitch, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontWeight: FontWeight.w600, fontSize: 13.5)),
                ],
              ),
            ),
            if (!isPro) Icon(Ph.caretRight, color: Colors.white.withValues(alpha: 0.9)),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title, this.tiles);
  final String title;
  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    if (tiles.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 24, 10, 10),
          child: Text(title, style: context.text.labelMedium?.copyWith(color: context.pal.inkFaint, letterSpacing: 0.3)),
        ),
        SoftCard(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              for (var i = 0; i < tiles.length; i++) ...[
                if (i > 0) Divider(indent: 70, endIndent: 16, color: context.pal.line),
                tiles[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.color, required this.title, this.subtitle, this.value, this.trailing, this.onTap});

  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Pressable(
      onTap: onTap,
      scale: 0.985,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        child: Row(
          children: [
            IconBubble(icon, color: color, size: 40),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.text.titleSmall),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: context.text.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ],
              ),
            ),
            if (value != null) ...[
              const SizedBox(width: 8),
              Text(value!, style: context.text.bodyMedium?.copyWith(color: p.inkFaint, fontWeight: FontWeight.w700)),
            ],
            if (trailing != null) trailing! else Icon(Ph.caretRight, size: 18, color: p.inkFaint),
          ],
        ),
      ),
    );
  }
}
