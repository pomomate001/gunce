import 'package:flutter/painting.dart';

/// Fonts an entry can be written in ("Yazı Tipi").
class EditorFont {
  const EditorFont(this.id, this.family, this.label, {this.isPro = false, this.scale = 1});

  final String id;
  final String family;
  final String label;
  final bool isPro;

  /// Optical size correction so every font reads at a similar size.
  final double scale;

  /// Text style in this font. The weight is also set as a `wght` variation because
  /// some families ship as unmodified variable fonts (OFL Reserved Font Names).
  TextStyle style({required double size, FontWeight weight = FontWeight.w400, Color? color, double? height}) => TextStyle(
        fontFamily: family,
        fontSize: size * scale,
        fontWeight: weight,
        fontVariations: [FontVariation('wght', weight == FontWeight.w700 ? 700 : 400)],
        color: color,
        height: height,
      );
}

abstract final class EditorFonts {
  static const defaultId = 'nunito';

  static EditorFont byId(String? id) => all.firstWhere((f) => f.id == id, orElse: () => all.first);

  static const all = <EditorFont>[
    EditorFont('nunito', 'Nunito', 'Nunito'),
    EditorFont('lora', 'Lora', 'Lora'),
    EditorFont('caveat', 'Caveat', 'Caveat', scale: 1.28),
    EditorFont('quicksand', 'Quicksand', 'Quicksand'),
    EditorFont('playfair', 'PlayfairDisplay', 'Playfair', isPro: true),
    EditorFont('dancing', 'DancingScript', 'Dancing', isPro: true, scale: 1.22),
    EditorFont('patrick', 'PatrickHand', 'Patrick', isPro: true, scale: 1.14),
    EditorFont('kalam', 'Kalam', 'Kalam', isPro: true, scale: 1.02),
    EditorFont('comfortaa', 'Comfortaa', 'Comfortaa', isPro: true, scale: 0.94),
    EditorFont('courier', 'CourierPrime', 'Courier', isPro: true),
    EditorFont('spacemono', 'SpaceMono', 'Space Mono', isPro: true, scale: 0.9),
    EditorFont('pacifico', 'Pacifico', 'Pacifico', isPro: true, scale: 0.9),
  ];
}

/// Ink colours for entry text. `null` (first) follows the page/theme ink.
const List<Color?> kInkColors = [
  null,
  Color(0xFF2F3A56),
  Color(0xFF5B3A29),
  Color(0xFFB5523B),
  Color(0xFFC2416E),
  Color(0xFF7D4BB5),
  Color(0xFF3F5FC4),
  Color(0xFF1F7EA1),
  Color(0xFF2E8B74),
  Color(0xFF4E7D34),
  Color(0xFF9A7B1F),
  Color(0xFFFFFFFF),
];
