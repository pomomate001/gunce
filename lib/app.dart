import 'dart:ui' show PlatformDispatcher, PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'config/app_config.dart';
import 'core/palette.dart';
import 'core/themes.dart';
import 'data/settings.dart';
import 'features/lock/lock_gate.dart';
import 'features/onboarding/onboarding_page.dart';
import 'features/shell/main_shell.dart';
import 'l10n/app_localizations.dart';
import 'services/pro_service.dart';

class GunceApp extends StatelessWidget {
  const GunceApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final isPro = context.select<ProController, bool>((p) => p.isPro);
    var spec = AppThemes.byId(settings.themeId);
    // A Premium theme falls back to the default when Premium ends (the choice is kept).
    if (spec.isPro && !isPro) spec = AppThemes.byId(null);
    final palette = spec.palette;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConfig.appName,
      theme: buildTheme(palette),
      themeAnimationDuration: const Duration(milliseconds: 450),
      scrollBehavior: const MaterialScrollBehavior().copyWith(dragDevices: PointerDeviceKind.values.toSet()),
      locale: settings.locale ?? _deviceLocale(),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: (palette.isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarContrastEnforced: false,
        ),
        child: child!,
      ),
      home: settings.onboarded ? const LockGate(child: MainShell()) : const OnboardingPage(),
    );
  }
}

/// First supported language in the phone's language list; English otherwise.
Locale _deviceLocale() {
  final supported = {for (final l in AppLocalizations.supportedLocales) l.languageCode};
  for (final l in PlatformDispatcher.instance.locales) {
    if (supported.contains(l.languageCode)) return Locale(l.languageCode);
  }
  return const Locale('en');
}
