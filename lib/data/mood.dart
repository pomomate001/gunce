import 'package:flutter/painting.dart';

import '../l10n/app_localizations.dart';

enum Mood {
  great(Color(0xFFFFC44D), 5),
  happy(Color(0xFFFFA466), 4),
  loved(Color(0xFFFF8DAA), 4),
  calm(Color(0xFF79D2B0), 4),
  meh(Color(0xFFB4BDD6), 3),
  anxious(Color(0xFFB09CEB), 2),
  sad(Color(0xFF78B4F0), 2),
  angry(Color(0xFFFF7466), 1);

  const Mood(this.color, this.valence);

  /// Mood colour, shared by every emoji pack (calendar, charts, pixels).
  final Color color;

  /// 1 (worst) .. 5 (best), used by the mood flow chart.
  final int valence;

  static Mood? byName(String? name) => name == null ? null : Mood.values.where((m) => m.name == name).firstOrNull;

  String label(AppLocalizations l) => switch (this) {
        Mood.great => l.moodGreat,
        Mood.happy => l.moodHappy,
        Mood.loved => l.moodLoved,
        Mood.calm => l.moodCalm,
        Mood.meh => l.moodMeh,
        Mood.anxious => l.moodAnxious,
        Mood.sad => l.moodSad,
        Mood.angry => l.moodAngry,
      };
}

class MoodPack {
  const MoodPack(this.id, this.name, this._asset, {this.isPro = false});

  final String id;
  final String Function(AppLocalizations) name;
  final String Function(Mood) _asset;
  final bool isPro;

  String asset(Mood m) => _asset(m);
}

String _own(String pack, Mood m) => 'assets/moods/$pack/${m.name}.webp';

String _fluent(Map<Mood, String> files, Mood m) => 'assets/moods/fluent/${files[m]}.webp';

abstract final class MoodPacks {
  static const defaultId = 'mochi';

  static MoodPack byId(String? id) => all.firstWhere((p) => p.id == id, orElse: () => all.first);

  static final all = <MoodPack>[
    MoodPack('mochi', (l) => l.packMochi, (m) => _own('mochi', m)),
    MoodPack(
      'classic',
      (l) => l.packClassic,
      (m) => _fluent(const {
        Mood.great: 'beaming_face_with_smiling_eyes',
        Mood.happy: 'smiling_face_with_smiling_eyes',
        Mood.loved: 'smiling_face_with_hearts',
        Mood.calm: 'relieved_face',
        Mood.meh: 'neutral_face',
        Mood.anxious: 'anxious_face_with_sweat',
        Mood.sad: 'crying_face',
        Mood.angry: 'pouting_face',
      }, m),
    ),
    MoodPack('bear', (l) => l.packBear, (m) => _own('bear', m), isPro: true),
    MoodPack('bunny', (l) => l.packBunny, (m) => _own('bunny', m), isPro: true),
    MoodPack('pup', (l) => l.packPup, (m) => _own('pup', m), isPro: true),
    MoodPack(
      'cats',
      (l) => l.packCats,
      (m) => _fluent(const {
        Mood.great: 'grinning_cat_with_smiling_eyes',
        Mood.happy: 'grinning_cat',
        Mood.loved: 'smiling_cat_with_heart_eyes',
        Mood.calm: 'kissing_cat',
        Mood.meh: 'cat_with_wry_smile',
        Mood.anxious: 'weary_cat',
        Mood.sad: 'crying_cat',
        Mood.angry: 'pouting_cat',
      }, m),
      isPro: true,
    ),
    MoodPack(
      'weather',
      (l) => l.packWeather,
      (m) => _fluent(const {
        Mood.great: 'sun',
        Mood.happy: 'sun_behind_small_cloud',
        Mood.loved: 'rainbow',
        Mood.calm: 'sun_behind_cloud',
        Mood.meh: 'cloud',
        Mood.anxious: 'tornado',
        Mood.sad: 'cloud_with_rain',
        Mood.angry: 'cloud_with_lightning_and_rain',
      }, m),
      isPro: true,
    ),
  ];
}
