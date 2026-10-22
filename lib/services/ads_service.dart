import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/app_config.dart';
import '../data/settings.dart';
import '../features/lock/lock_gate.dart';
import 'pro_service.dart';

/// AdMob for the free version.
///
/// * Interstitials after an entry is saved, and once 30 minutes of use have
///   passed, shown at the next natural pause (tab change, leaving a screen),
///   never while the user is typing. Two interstitials are at least
///   [AdConfig.interstitialMinGap] apart.
/// * Nothing at all for Pro users.
class AdsService with WidgetsBindingObserver {
  AdsService._();
  static final instance = AdsService._();

  late SettingsController _settings;
  late ProController _pro;
  bool _started = false;
  bool _sdkReady = false;
  InterstitialAd? _interstitial;
  bool _loading = false;
  DateTime? _lastShown;
  final _usage = Stopwatch();

  bool privacyOptionsRequired = false;

  bool get _allowed => AdConfig.enabled && !kIsWeb && !_pro.isPro;

  void attach(SettingsController settings, ProController pro) {
    _settings = settings;
    _pro = pro;
    pro.addListener(_syncPro);
    WidgetsBinding.instance.addObserver(this);
  }

  /// Called once the onboarding is finished: asks for consent where the law
  /// requires it (UMP: EEA/UK/CH), then starts the SDK.
  Future<void> start() async {
    if (_started || !_allowed) return;
    _started = true;
    try {
      await _gatherConsent();
      if (!await ConsentInformation.instance.canRequestAds()) return;
      await MobileAds.instance.initialize();
      _sdkReady = true;
      _usage.start();
      _syncPro();
      _loadInterstitial();
    } catch (e) {
      debugPrint('ads start failed: $e');
    }
  }

  Future<void> _gatherConsent() {
    final done = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () => ConsentForm.loadAndShowConsentFormIfRequired((_) async {
        privacyOptionsRequired = await ConsentInformation.instance.getPrivacyOptionsRequirementStatus() ==
            PrivacyOptionsRequirementStatus.required;
        if (!done.isCompleted) done.complete();
      }),
      (_) {
        if (!done.isCompleted) done.complete();
      },
    );
    return done.future;
  }

  Future<void> showPrivacyOptions() => ConsentForm.showPrivacyOptionsForm((_) {});

  AdRequest get request => AdRequest(nonPersonalizedAds: !_settings.adsPersonalized);

  void _syncPro() {
    if (!(_sdkReady && _allowed)) {
      _interstitial?.dispose();
      _interstitial = null;
    } else if (_interstitial == null) {
      _loadInterstitial();
    }
  }

  void _loadInterstitial() {
    if (!_sdkReady || !_allowed || _loading || _interstitial != null) return;
    _loading = true;
    InterstitialAd.load(
      adUnitId: AdConfig.interstitial,
      request: request,
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _loading = false;
          _interstitial = ad;
        },
        onAdFailedToLoad: (error) {
          _loading = false;
          Timer(const Duration(minutes: 1), _loadInterstitial);
        },
      ),
    );
  }

  bool get _gapOk => _lastShown == null || DateTime.now().difference(_lastShown!) >= AdConfig.interstitialMinGap;

  /// After an entry has been saved.
  Future<void> onEntrySaved() => _show();

  /// At a natural pause; only shows once [AdConfig.interstitialEvery] of use has passed.
  Future<void> onNaturalBreak() async {
    if (_usage.elapsed >= AdConfig.interstitialEvery) await _show();
  }

  Future<void> _show() async {
    if (!_sdkReady || !_allowed || !_gapOk) return;
    final ad = _interstitial;
    if (ad == null) {
      _loadInterstitial();
      return;
    }
    _interstitial = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _loadInterstitial();
      },
    );
    _lastShown = DateTime.now();
    _usage
      ..reset()
      ..start();
    LockGate.allowBackground(const Duration(minutes: 3));
    await ad.show();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_sdkReady) _usage.start();
    } else if (state == AppLifecycleState.paused) {
      _usage.stop();
    }
  }
}
