import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../config/app_config.dart';
import '../data/settings.dart';

/// Developer switches (Pro simulation) only exist in builds made with
/// `--dart-define=GUNCE_DEV=true`; store builds never have them.
const kDevTools = bool.fromEnvironment('GUNCE_DEV');

enum PurchaseOutcome { success, cancelled, failed }

/// Premium entitlement through RevenueCat (Google Play Billing underneath).
class ProController extends ChangeNotifier {
  ProController(this._settings) : _isPro = _settings.proCache;

  final SettingsController _settings;
  bool _isPro;
  bool _devPro = false;
  bool _configured = false;
  Offering? offering;

  bool get isPro => _isPro || _devPro;

  /// False until a RevenueCat key is configured (see AppConfig) and the SDK started.
  bool get storeReady => _configured;

  Future<void> init() async {
    if (kIsWeb || PurchaseConfig.revenueCatGoogleApiKey.isEmpty) return;
    try {
      await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.warn);
      await Purchases.configure(PurchasesConfiguration(PurchaseConfig.revenueCatGoogleApiKey));
      _configured = true;
      Purchases.addCustomerInfoUpdateListener(_apply);
      _apply(await Purchases.getCustomerInfo());
      await loadOffering();
    } catch (e) {
      debugPrint('RevenueCat init failed: $e');
    }
    notifyListeners();
  }

  Future<void> loadOffering() async {
    if (!_configured) return;
    try {
      offering = (await Purchases.getOfferings()).current;
      notifyListeners();
    } catch (e) {
      debugPrint('RevenueCat offerings failed: $e');
    }
  }

  void _apply(CustomerInfo info) {
    final active = info.entitlements.active.containsKey(PurchaseConfig.entitlementId);
    if (active == _isPro) return;
    _isPro = active;
    _settings.setProCache(active);
    notifyListeners();
  }

  Future<PurchaseOutcome> buy(Package package) async {
    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      _apply(result.customerInfo);
      return isPro ? PurchaseOutcome.success : PurchaseOutcome.failed;
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      return code == PurchasesErrorCode.purchaseCancelledError ? PurchaseOutcome.cancelled : PurchaseOutcome.failed;
    }
  }

  Future<bool> restore() async {
    if (!_configured) return false;
    try {
      _apply(await Purchases.restorePurchases());
    } catch (e) {
      debugPrint('restore failed: $e');
    }
    return isPro;
  }

  void toggleDevPro() {
    if (!kDevTools) return;
    _devPro = !_devPro;
    notifyListeners();
  }
}
