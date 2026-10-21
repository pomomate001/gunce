import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_config.dart';
import '../../core/scene.dart';
import '../../core/themes.dart';
import '../../core/widgets.dart';
import '../../data/stickers.dart';
import '../../services/pro_service.dart';
import '../lock/lock_gate.dart';

/// Returns true if the user is (or just became) Premium.
Future<bool> ensurePro(BuildContext context) async {
  final pro = context.read<ProController>();
  if (pro.isPro) return true;
  await Navigator.of(context).push(PaywallPage.route());
  return pro.isPro;
}

class PaywallPage extends StatefulWidget {
  const PaywallPage({super.key, this.onDone});

  /// Used by onboarding: called instead of popping.
  final VoidCallback? onDone;

  static Route<void> route() => PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, _, _) => const PaywallPage(),
        transitionsBuilder: (_, a, _, c) => SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: Offset.zero).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
          child: c,
        ),
      );

  @override
  State<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends State<PaywallPage> {
  Package? _selected;
  bool _busy = false;

  void _close() => widget.onDone != null ? widget.onDone!() : Navigator.pop(context);

  List<Package> _packages(ProController pro) {
    final list = [...?pro.offering?.availablePackages];
    int rank(Package p) => switch (p.packageType) {
          PackageType.annual => 0,
          PackageType.lifetime => 1,
          PackageType.monthly => 2,
          _ => 3,
        };
    list.sort((a, b) => rank(a).compareTo(rank(b)));
    return list;
  }

  Future<void> _buy(ProController pro) async {
    final pkg = _selected;
    if (pkg == null) return;
    setState(() => _busy = true);
    LockGate.allowBackground(const Duration(minutes: 5));
    final result = await pro.buy(pkg);
    if (!mounted) return;
    setState(() => _busy = false);
    switch (result) {
      case PurchaseOutcome.success:
        toast(context, context.l.welcomePremium, icon: PhFill.crownSimple);
        _close();
      case PurchaseOutcome.failed:
        toast(context, context.l.purchaseFailed);
      case PurchaseOutcome.cancelled:
        break;
    }
  }

  Future<void> _restore(ProController pro) async {
    setState(() => _busy = true);
    final ok = await pro.restore();
    if (!mounted) return;
    setState(() => _busy = false);
    toast(context, ok ? context.l.restoreSuccess : context.l.restoreNothing);
    if (ok) _close();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final l = context.l;
    final pro = context.watch<ProController>();
    final packages = _packages(pro);
    _selected ??= packages.firstOrNull;
    final ready = pro.storeReady && packages.isNotEmpty;
    final sceneSpec = AppThemes.byId('sunset').scene;

    final features = [
      (PhFill.palette, l.proThemes(AppThemes.all.length)),
      (PhFill.smiley, l.proMoodPacks),
      (PhFill.sticker, l.proStickers(Stickers.count)),
      (PhFill.textAa, l.proFonts),
      (PhFill.shieldCheck, l.proNoAds),
    ];

    return Scaffold(
      body: Stack(
        children: [
          SizedBox(height: 300, width: double.infinity, child: SceneView(spec: sceneSpec)),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [p.bg.withValues(alpha: 0), p.bg.withValues(alpha: 0), p.bg],
                  stops: const [0, 0.18, 0.36],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: CircleButton(icon: Ph.x, onTap: _close, background: Colors.white.withValues(alpha: 0.75), color: const Color(0xFF2B2758)),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 90, 24, 24),
                    children: [
                      Center(child: ProBadge(size: 56)),
                      const SizedBox(height: 14),
                      Text(l.premiumTitle, textAlign: TextAlign.center, style: context.text.displaySmall),
                      const SizedBox(height: 8),
                      Text(l.premiumSubtitle, textAlign: TextAlign.center, style: context.text.bodyMedium),
                      const SizedBox(height: 24),
                      SoftCard(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        child: Column(
                          children: [
                            for (final (icon, text) in features)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 9),
                                child: Row(children: [
                                  IconBubble(icon, size: 36),
                                  const SizedBox(width: 14),
                                  Expanded(child: Text(text, style: context.text.titleSmall)),
                                  Icon(PhBold.check, color: p.accent, size: 18),
                                ]),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      if (ready)
                        for (final pkg in packages)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _PlanTile(
                              package: pkg,
                              selected: identical(pkg, _selected),
                              best: pkg.packageType == PackageType.annual,
                              onTap: () => setState(() => _selected = pkg),
                            ),
                          )
                      else
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(color: p.accentSoft, borderRadius: BorderRadius.circular(22)),
                          child: Row(children: [
                            Icon(PhFill.sparkle, color: p.accent),
                            const SizedBox(width: 12),
                            Expanded(child: Text(l.premiumSoon, style: context.text.bodyMedium?.copyWith(color: p.ink))),
                          ]),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                  child: AppButton(
                    label: ready ? l.goPremium : l.comingSoon,
                    icon: PhFill.crownSimple,
                    loading: _busy,
                    onTap: ready ? () => _buy(pro) : null,
                  ),
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    if (pro.storeReady) _LinkText(l.restorePurchases, () => _restore(pro)),
                    _LinkText(l.terms, () => launchUrl(Uri.parse(AppConfig.termsUrl))),
                    _LinkText(l.privacyPolicy, () => launchUrl(Uri.parse(AppConfig.privacyPolicyUrl))),
                  ],
                ),
                if (ready)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 0, 28, 10),
                    child: Text(l.subscriptionNote, textAlign: TextAlign.center, style: context.text.bodySmall),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({required this.package, required this.selected, required this.best, required this.onTap});
  final Package package;
  final bool selected;
  final bool best;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final l = context.l;
    final product = package.storeProduct;
    final title = switch (package.packageType) {
      PackageType.annual => l.planYearly,
      PackageType.monthly => l.planMonthly,
      PackageType.lifetime => l.planLifetime,
      _ => product.title,
    };
    final suffix = switch (package.packageType) {
      PackageType.annual => l.perYear,
      PackageType.monthly => l.perMonth,
      _ => '',
    };
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? p.accentSoft : p.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: selected ? p.accent : p.line, width: selected ? 2.2 : 1.2),
        ),
        child: Row(
          children: [
            Icon(selected ? PhFill.checkCircle : Ph.circle, color: selected ? p.accent : p.inkFaint),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(title, style: context.text.titleMedium),
                    if (best) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: p.accent, borderRadius: BorderRadius.circular(10)),
                        child: Text(l.bestValue, style: TextStyle(color: p.onAccent, fontSize: 11, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ]),
                ],
              ),
            ),
            Text('${product.priceString}$suffix', style: context.text.titleMedium?.copyWith(color: p.accent)),
          ],
        ),
      ),
    );
  }
}

class _LinkText extends StatelessWidget {
  const _LinkText(this.label, this.onTap);
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: onTap,
        child: Text(label, style: context.text.bodySmall?.copyWith(decoration: TextDecoration.underline)),
      );
}
