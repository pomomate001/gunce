/// Everything that has to be filled in for the store release lives in this file.
library;

import 'package:flutter/foundation.dart';

abstract final class AppConfig {
  static const appName = 'Günce';
  static const packageName = 'com.yusuf.gunce';

  /// Must be a public URL before the Play Store review (ads use the Advertising ID).
  static const privacyPolicyUrl = 'https://pomomate001.github.io/gunce/privacy.html';
  static const termsUrl = 'https://pomomate001.github.io/gunce/terms.html';
  static const playStoreUrl = 'https://play.google.com/store/apps/details?id=$packageName';
}

abstract final class AdConfig {
  static const enabled = true;

  /// Real AdMob ad unit id. Google's official test unit is used while it is
  /// empty and in debug/profile builds, so our own ads are never clicked while developing.
  /// The AdMob *app* id is in android/gradle.properties (admobAppId).
  static const interstitialUnitId = 'ca-app-pub-1530810645169749/8357658628';

  static const testInterstitialUnitId = 'ca-app-pub-3940256099942544/1033173712';

  /// An interstitial becomes due after this much time in the app...
  static const interstitialEvery = Duration(minutes: 30);

  /// ...and two interstitials are never closer than this (also applies to saves).
  static const interstitialMinGap = Duration(minutes: 2);

  static String get interstitial => !kReleaseMode || interstitialUnitId.isEmpty ? testInterstitialUnitId : interstitialUnitId;
}

abstract final class PurchaseConfig {
  /// RevenueCat public Google API key (starts with "goog_"). Empty = purchases off.
  static const revenueCatGoogleApiKey = '';
  static const entitlementId = 'pro';
}
