import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/widgets.dart';
import '../../data/settings.dart';
import '../../services/lock_service.dart';
import 'lock_gate.dart';

/// Create a new 4-digit PIN (enter twice). Pops `true` when saved.
class PinSetupPage extends StatefulWidget {
  const PinSetupPage({super.key});

  @override
  State<PinSetupPage> createState() => _PinSetupPageState();
}

class _PinSetupPageState extends State<PinSetupPage> with SingleTickerProviderStateMixin {
  String _first = '';
  String _pin = '';
  bool _confirming = false;
  bool _mismatch = false;
  late final _shake = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  Future<void> _digit(String d) async {
    if (_pin.length >= 4) return;
    setState(() {
      _pin += d;
      _mismatch = false;
    });
    if (_pin.length < 4) return;
    await Future.delayed(const Duration(milliseconds: 120));
    if (!_confirming) {
      setState(() {
        _first = _pin;
        _pin = '';
        _confirming = true;
      });
    } else if (_pin == _first) {
      final salt = LockService.newSalt();
      if (!mounted) return;
      await context.read<SettingsController>().setPin(LockService.hash(_pin, salt), salt);
      HapticFeedback.lightImpact();
      if (mounted) Navigator.pop(context, true);
    } else {
      HapticFeedback.heavyImpact();
      _shake.forward(from: 0);
      setState(() {
        _mismatch = true;
        _pin = '';
        _first = '';
        _confirming = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final p = context.pal;
    return Scaffold(
      appBar: AppBar(leading: CircleButton(icon: Ph.arrowLeft, onTap: () => Navigator.pop(context), background: Colors.transparent)),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            IconBubble(PhFill.lockKey, size: 72),
            const SizedBox(height: 20),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: Text(
                _confirming ? l.confirmPin : l.createPin,
                key: ValueKey(_confirming),
                style: context.text.headlineMedium,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                _mismatch ? l.pinMismatch : l.pinHint,
                textAlign: TextAlign.center,
                style: context.text.bodyMedium?.copyWith(color: _mismatch ? const Color(0xFFE5484D) : p.inkSoft),
              ),
            ),
            const SizedBox(height: 26),
            AnimatedBuilder(
              animation: _shake,
              builder: (_, child) => Transform.translate(offset: Offset(math.sin(_shake.value * math.pi * 6) * 12 * (1 - _shake.value), 0), child: child),
              child: PinDots(filled: _pin.length, error: _mismatch),
            ),
            const Spacer(),
            PinPad(onDigit: _digit, onBackspace: () => setState(() => _pin = _pin.isEmpty ? '' : _pin.substring(0, _pin.length - 1))),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}
