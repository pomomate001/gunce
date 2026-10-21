import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/mood.dart';
import '../data/settings.dart';
import '../services/pro_service.dart';
import '../l10n/app_localizations.dart';
import 'icons.dart';
import 'palette.dart';

export 'icons.dart';

extension ContextX on BuildContext {
  AppPalette get pal => AppPalette.of(this);
  AppLocalizations get l => AppLocalizations.of(this);
  TextTheme get text => Theme.of(this).textTheme;
  String get lang => Localizations.localeOf(this).languageCode;
}

/// Gentle press-down scale used by every tappable surface.
class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.child, this.onTap, this.onLongPress, this.scale = 0.965, this.semanticLabel});

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scale;
  final String? semanticLabel;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null || widget.onLongPress != null;
    return Semantics(
      button: enabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => _set(true) : null,
        onTapUp: enabled ? (_) => _set(false) : null,
        onTapCancel: () => _set(false),
        onTap: widget.onTap == null
            ? null
            : () {
                HapticFeedback.selectionClick();
                widget.onTap!();
              },
        onLongPress: widget.onLongPress == null
            ? null
            : () {
                _set(false);
                HapticFeedback.mediumImpact();
                widget.onLongPress!();
              },
        child: AnimatedScale(
          scale: _down ? widget.scale : 1,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}

enum ButtonKind { primary, soft, ghost }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.kind = ButtonKind.primary,
    this.expand = true,
    this.loading = false,
    this.height = 56,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final ButtonKind kind;
  final bool expand;
  final bool loading;
  final double height;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final enabled = onTap != null && !loading;
    final (bg, fg) = switch (kind) {
      ButtonKind.primary => (p.accent, p.onAccent),
      ButtonKind.soft => (p.accentSoft, p.accent),
      ButtonKind.ghost => (Colors.transparent, p.inkSoft),
    };
    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.4, color: fg))
        else ...[
          if (icon != null) ...[Icon(icon, color: fg, size: 20), const SizedBox(width: 8)],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontFamily: kBodyFont, fontSize: 16, fontWeight: FontWeight.w800, color: fg, letterSpacing: 0.1),
            ),
          ),
        ],
      ],
    );
    return Opacity(
      opacity: enabled || loading ? 1 : 0.45,
      child: Pressable(
        onTap: enabled ? onTap : null,
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(height / 2),
            boxShadow: kind == ButtonKind.primary && enabled
                ? [BoxShadow(color: p.accent.withValues(alpha: 0.32), blurRadius: 18, offset: const Offset(0, 8))]
                : null,
          ),
          child: content,
        ),
      ),
    );
  }
}

class SoftCard extends StatelessWidget {
  const SoftCard({super.key, required this.child, this.padding = const EdgeInsets.all(20), this.onTap, this.onLongPress, this.color, this.radius = 26});

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? p.surface,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: p.softShadow,
        border: p.isDark ? Border.all(color: p.line.withValues(alpha: 0.6)) : null,
      ),
      child: child,
    );
    if (onTap == null && onLongPress == null) return card;
    return Pressable(onTap: onTap, onLongPress: onLongPress, scale: 0.98, child: card);
  }
}

/// Small crown marking Premium-only content.
class ProBadge extends StatelessWidget {
  const ProBadge({super.key, this.size = 22});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(colors: [Color(0xFFFFC155), Color(0xFFFF7E5F)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        border: Border.all(color: Colors.white, width: 1.6),
        boxShadow: [BoxShadow(color: const Color(0xFFFF7E5F).withValues(alpha: 0.35), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Icon(PhFill.crownSimple, size: size * 0.55, color: Colors.white),
    );
  }
}

/// Mood artwork from the user's emoji pack (or [pack]).
class MoodIcon extends StatelessWidget {
  const MoodIcon(this.mood, {super.key, this.size = 40, this.pack});

  final Mood? mood;
  final double size;
  final MoodPack? pack;

  @override
  Widget build(BuildContext context) {
    final m = mood;
    if (m == null) {
      final p = context.pal;
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: p.surface2, border: Border.all(color: p.line, width: 1.5)),
        child: Icon(Ph.smileyWink, size: size * 0.5, color: p.inkFaint),
      );
    }
    final selected = context.select<SettingsController, MoodPack>((s) => s.moodPack);
    final isPro = context.select<ProController, bool>((p) => p.isPro);
    final pk = pack ?? (selected.isPro && !isPro ? MoodPacks.byId(null) : selected);
    return Image.asset(
      pk.asset(m),
      width: size,
      height: size,
      filterQuality: FilterQuality.medium,
      gaplessPlayback: true,
      semanticLabel: m.label(context.l),
    );
  }
}

class IconBubble extends StatelessWidget {
  const IconBubble(this.icon, {super.key, this.color, this.size = 40});
  final IconData icon;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.pal.accent;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: c.withValues(alpha: context.pal.isDark ? 0.2 : 0.13), borderRadius: BorderRadius.circular(size * 0.36)),
      child: Icon(icon, color: c, size: size * 0.52),
    );
  }
}

/// Round icon button for top bars.
class CircleButton extends StatelessWidget {
  const CircleButton({super.key, required this.icon, this.onTap, this.size = 44, this.background, this.color, this.tooltip});

  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final Color? background;
  final Color? color;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final btn = Pressable(
      onTap: onTap,
      scale: 0.9,
      semanticLabel: tooltip,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: background ?? p.surface.withValues(alpha: 0.82)),
        child: Icon(icon, size: size * 0.48, color: color ?? p.ink),
      ),
    );
    return tooltip == null ? btn : Tooltip(message: tooltip!, child: btn);
  }
}

/// Header used inside bottom sheets.
class SheetHeader extends StatelessWidget {
  const SheetHeader({super.key, required this.title, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Column(
      children: [
        const SizedBox(height: 10),
        Container(width: 40, height: 4.5, decoration: BoxDecoration(color: p.line, borderRadius: BorderRadius.circular(3))),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 16, 8),
          child: Row(
            children: [
              Expanded(child: Text(title, style: context.text.headlineSmall)),
              if (action != null)
                AppButton(label: action!, onTap: onAction ?? () => Navigator.of(context).pop(), expand: false, height: 40),
            ],
          ),
        ),
      ],
    );
  }
}

Future<T?> showAppSheet<T>(BuildContext context, WidgetBuilder builder, {double? maxHeightFactor}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    constraints: maxHeightFactor == null ? null : BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * maxHeightFactor),
    builder: builder,
  );
}

Future<bool> confirm(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final p = context.pal;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(ctx.l.cancel, style: TextStyle(color: p.inkSoft, fontWeight: FontWeight.w700)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(
            confirmLabel,
            style: TextStyle(color: destructive ? const Color(0xFFE5484D) : p.accent, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    ),
  );
  return ok ?? false;
}

void toast(BuildContext context, String message, {IconData? icon}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(SnackBar(
    duration: const Duration(milliseconds: 2400),
    content: Row(children: [
      if (icon != null) ...[Icon(icon, size: 20, color: Theme.of(context).snackBarTheme.contentTextStyle?.color), const SizedBox(width: 10)],
      Expanded(child: Text(message)),
    ]),
  ));
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.title, required this.message, this.mood = Mood.calm, this.action});
  final String title;
  final String message;
  final Mood mood;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Floating(child: MoodIcon(mood, size: 92)),
          const SizedBox(height: 18),
          Text(title, textAlign: TextAlign.center, style: context.text.headlineSmall),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center, style: context.text.bodyMedium),
          if (action != null) ...[const SizedBox(height: 20), action!],
        ],
      ),
    );
  }
}

/// Slow up/down bob, used for illustrations.
class Floating extends StatefulWidget {
  const Floating({super.key, required this.child});
  final Widget child;

  @override
  State<Floating> createState() => _FloatingState();
}

class _FloatingState extends State<Floating> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) => Transform.translate(offset: Offset(0, -6 * Curves.easeInOut.transform(_c.value)), child: child),
      child: widget.child,
    );
  }
}

/// Fades and slides a list item in, staggered by [index].
class EnterAnimation extends StatelessWidget {
  const EnterAnimation({super.key, required this.index, required this.child});
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final delay = (index.clamp(0, 8)) * 45;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 420 + delay),
      curve: Interval(delay / (420 + delay), 1, curve: Curves.easeOutCubic),
      builder: (_, v, c) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, 18 * (1 - v)), child: c)),
      child: child,
    );
  }
}
