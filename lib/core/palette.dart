import 'package:flutter/material.dart';

/// Colour roles of a Günce theme. Every screen reads colours from here, never
/// from hard-coded values, so a theme switch restyles the whole app.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.brightness,
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.accent,
    required this.onAccent,
    required this.ink,
    required this.inkSoft,
    required this.inkFaint,
    required this.line,
  });

  final Brightness brightness;
  final Color bg;
  final Color surface;
  final Color surface2;
  final Color accent;
  final Color onAccent;
  final Color ink;
  final Color inkSoft;
  final Color inkFaint;
  final Color line;

  bool get isDark => brightness == Brightness.dark;
  Color get accentSoft => Color.alphaBlend(accent.withValues(alpha: isDark ? 0.22 : 0.13), surface);
  Color get shadow => isDark ? Colors.black.withValues(alpha: 0.35) : ink.withValues(alpha: 0.07);

  static AppPalette of(BuildContext context) => Theme.of(context).extension<AppPalette>()!;

  List<BoxShadow> get softShadow => [
        BoxShadow(color: shadow, blurRadius: 28, offset: const Offset(0, 10)),
        BoxShadow(color: shadow.withValues(alpha: shadow.a * 0.6), blurRadius: 3, offset: const Offset(0, 1)),
      ];

  @override
  AppPalette copyWith({Color? accent}) => AppPalette(
        brightness: brightness,
        bg: bg,
        surface: surface,
        surface2: surface2,
        accent: accent ?? this.accent,
        onAccent: onAccent,
        ink: ink,
        inkSoft: inkSoft,
        inkFaint: inkFaint,
        line: line,
      );

  @override
  AppPalette lerp(covariant AppPalette? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      brightness: t < 0.5 ? brightness : other.brightness,
      bg: l(bg, other.bg),
      surface: l(surface, other.surface),
      surface2: l(surface2, other.surface2),
      accent: l(accent, other.accent),
      onAccent: l(onAccent, other.onAccent),
      ink: l(ink, other.ink),
      inkSoft: l(inkSoft, other.inkSoft),
      inkFaint: l(inkFaint, other.inkFaint),
      line: l(line, other.line),
    );
  }
}

const kDisplayFont = 'Fraunces';
const kBodyFont = 'Nunito';

ThemeData buildTheme(AppPalette p) {
  final scheme = ColorScheme.fromSeed(
    seedColor: p.accent,
    brightness: p.brightness,
  ).copyWith(
    primary: p.accent,
    onPrimary: p.onAccent,
    surface: p.surface,
    onSurface: p.ink,
    onSurfaceVariant: p.inkSoft,
    outline: p.line,
    outlineVariant: p.line,
    secondary: p.accent,
  );

  TextStyle body(double size, FontWeight w, Color c, {double h = 1.4}) =>
      TextStyle(fontFamily: kBodyFont, fontSize: size, fontWeight: w, color: c, height: h);
  TextStyle display(double size, Color c) =>
      TextStyle(fontFamily: kDisplayFont, fontSize: size, fontWeight: FontWeight.w600, color: c, height: 1.15, letterSpacing: -0.2);

  final text = TextTheme(
    displayLarge: display(44, p.ink),
    displayMedium: display(34, p.ink),
    displaySmall: display(28, p.ink),
    headlineMedium: display(24, p.ink),
    headlineSmall: display(21, p.ink),
    titleLarge: display(19, p.ink),
    titleMedium: body(16.5, FontWeight.w700, p.ink),
    titleSmall: body(14.5, FontWeight.w700, p.ink),
    bodyLarge: body(16.5, FontWeight.w400, p.ink, h: 1.5),
    bodyMedium: body(14.5, FontWeight.w400, p.inkSoft, h: 1.45),
    bodySmall: body(12.5, FontWeight.w600, p.inkFaint),
    labelLarge: body(15.5, FontWeight.w700, p.ink),
    labelMedium: body(13, FontWeight.w700, p.inkSoft),
    labelSmall: body(11, FontWeight.w700, p.inkFaint, h: 1.2),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: p.brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: p.bg,
    canvasColor: p.bg,
    fontFamily: kBodyFont,
    textTheme: text,
    extensions: [p],
    splashFactory: InkSparkle.splashFactory,
    dividerTheme: DividerThemeData(color: p.line, thickness: 1, space: 1),
    iconTheme: IconThemeData(color: p.ink, size: 24),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      foregroundColor: p.ink,
      titleTextStyle: display(21, p.ink),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: p.isDark ? p.surface2 : p.ink,
      contentTextStyle: body(14.5, FontWeight.w600, p.isDark ? p.ink : p.bg),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: p.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      titleTextStyle: display(22, p.ink),
      contentTextStyle: body(15, FontWeight.w400, p.inkSoft, h: 1.5),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: p.surface,
      surfaceTintColor: Colors.transparent,
      modalBarrierColor: Colors.black.withValues(alpha: p.isDark ? 0.55 : 0.32),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      clipBehavior: Clip.antiAlias,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? p.onAccent : p.inkFaint),
      trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? p.accent : p.surface2),
      trackOutlineColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? p.accent : p.line),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: p.accent,
      selectionColor: p.accent.withValues(alpha: 0.25),
      selectionHandleColor: p.accent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: InputBorder.none,
      hintStyle: body(16, FontWeight.w400, p.inkFaint),
    ),
    timePickerTheme: TimePickerThemeData(
      backgroundColor: p.surface,
      dialBackgroundColor: p.surface2,
      hourMinuteColor: p.surface2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: p.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      headerHeadlineStyle: display(26, p.ink),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {TargetPlatform.android: FadeForwardsPageTransitionsBuilder()},
    ),
  );
}
