import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/palette.dart';
import '../../core/widgets.dart';
import '../../data/mood.dart';
import '../../data/settings.dart';
import '../../services/lock_service.dart';

/// Shows the PIN screen on start and after the app was in the background.
class LockGate extends StatefulWidget {
  const LockGate({super.key, required this.child});
  final Widget child;

  static DateTime? _allowUntil;

  /// Camera, gallery, file pickers and ads leave the app briefly; this keeps it unlocked.
  static void allowBackground(Duration d) => _allowUntil = DateTime.now().add(d);

  @override
  State<LockGate> createState() => _LockGateState();
}

class _LockGateState extends State<LockGate> with WidgetsBindingObserver {
  static const _grace = Duration(seconds: 20);
  late bool _locked;
  DateTime? _awaySince;

  @override
  void initState() {
    super.initState();
    _locked = context.read<SettingsController>().hasPin;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.hidden || state == AppLifecycleState.paused) {
      _awaySince ??= DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      final since = _awaySince;
      _awaySince = null;
      final now = DateTime.now();
      final allowed = LockGate._allowUntil != null && now.isBefore(LockGate._allowUntil!);
      if (since != null && !allowed && now.difference(since) > _grace && context.read<SettingsController>().hasPin) {
        setState(() => _locked = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TickerMode(enabled: !_locked, child: ExcludeSemantics(excluding: _locked, child: widget.child)),
        if (_locked) Positioned.fill(child: LockScreen(onUnlocked: () => setState(() => _locked = false))),
      ],
    );
  }
}

class LockScreen extends StatefulWidget {
  const LockScreen({super.key, required this.onUnlocked});
  final VoidCallback onUnlocked;

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> with SingleTickerProviderStateMixin {
  String _pin = '';
  bool _error = false;
  bool _bioAvailable = false;
  late final _shake = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));

  @override
  void initState() {
    super.initState();
    final s = context.read<SettingsController>();
    if (s.biometric) {
      LockService.biometricAvailable().then((ok) {
        if (!mounted) return;
        setState(() => _bioAvailable = ok);
        if (ok) _biometric();
      });
    }
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  Future<void> _biometric() async {
    LockGate.allowBackground(const Duration(seconds: 30));
    if (await LockService.authenticate(context.l.unlockReason)) widget.onUnlocked();
  }

  void _digit(String d) {
    if (_pin.length >= 4) return;
    setState(() {
      _pin += d;
      _error = false;
    });
    if (_pin.length == 4) _check();
  }

  void _check() {
    final s = context.read<SettingsController>();
    if (LockService.hash(_pin, s.pinSalt ?? '') == s.pinHash) {
      HapticFeedback.lightImpact();
      widget.onUnlocked();
    } else {
      HapticFeedback.heavyImpact();
      _shake.forward(from: 0);
      setState(() {
        _error = true;
        _pin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final l = context.l;
    return Material(
      color: p.bg,
      child: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            Floating(child: MoodIcon(Mood.calm, size: 84)),
            const SizedBox(height: 18),
            Text(l.welcomeBack, style: context.text.headlineMedium),
            const SizedBox(height: 6),
            Text(_error ? l.wrongPin : l.enterPin, style: context.text.bodyMedium?.copyWith(color: _error ? const Color(0xFFE5484D) : null)),
            const SizedBox(height: 26),
            AnimatedBuilder(
              animation: _shake,
              builder: (_, child) => Transform.translate(offset: Offset(math.sin(_shake.value * math.pi * 6) * 12 * (1 - _shake.value), 0), child: child),
              child: PinDots(filled: _pin.length, error: _error),
            ),
            const Spacer(flex: 2),
            PinPad(
              onDigit: _digit,
              onBackspace: () => setState(() => _pin = _pin.isEmpty ? '' : _pin.substring(0, _pin.length - 1)),
              leftAction: _bioAvailable ? (icon: Ph.fingerprint, onTap: _biometric) : null,
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

class PinDots extends StatelessWidget {
  const PinDots({super.key, required this.filled, this.error = false});
  final int filled;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 4; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            margin: const EdgeInsets.symmetric(horizontal: 9),
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: error ? const Color(0xFFE5484D) : (i < filled ? p.accent : Colors.transparent),
              border: Border.all(color: error ? const Color(0xFFE5484D) : (i < filled ? p.accent : p.inkFaint), width: 2),
            ),
          ),
      ],
    );
  }
}

class PinPad extends StatelessWidget {
  const PinPad({super.key, required this.onDigit, required this.onBackspace, this.leftAction});
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final ({IconData icon, VoidCallback onTap})? leftAction;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    Widget key(Widget child, VoidCallback? onTap, {bool filled = true}) => Pressable(
          onTap: onTap,
          scale: 0.88,
          child: Container(
            width: 76,
            height: 76,
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle, color: filled ? p.surface : Colors.transparent, boxShadow: filled ? p.softShadow : null),
            child: child,
          ),
        );
    Widget digit(String d) => key(Text(d, style: TextStyle(fontFamily: kDisplayFont, fontSize: 30, fontWeight: FontWeight.w600, color: p.ink)), () => onDigit(d));

    return Column(
      children: [
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [for (final d in row) digit(d)]),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            leftAction == null
                ? const SizedBox(width: 76)
                : key(Icon(leftAction!.icon, size: 30, color: p.accent), leftAction!.onTap, filled: false),
            digit('0'),
            key(Icon(Ph.backspace, size: 28, color: p.inkSoft), onBackspace, filled: false),
          ],
        ),
      ],
    );
  }
}
