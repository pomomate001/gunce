import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../core/scene.dart';
import '../core/themes.dart';
import '../data/entries_controller.dart';
import '../data/entry.dart';
import '../data/media_store.dart';
import '../data/mood.dart';
import '../data/settings.dart';

/// Builds made with `--dart-define=GUNCE_DEMO=true` (store screenshots) also seed on Android.
const kDemoData = bool.fromEnvironment('GUNCE_DEMO');

/// Sample pages for the web design preview and screenshot builds; never in store builds.
Future<void> seedDemoData(EntriesController entries, SettingsController settings) async {
  if (entries.entries.isNotEmpty) return;
  final tr = (settings.languageCode ?? ui.PlatformDispatcher.instance.locale.languageCode) == 'tr';
  final now = DateTime.now();
  final rnd = math.Random(4);

  Future<String> photo(String theme) async {
    const w = 900, h = 640;
    final rec = ui.PictureRecorder();
    ScenePainter(AppThemes.byId(theme).scene, const AlwaysStoppedAnimation(0.3), SceneCache())
        .paint(Canvas(rec), const Size(900, 640));
    final img = await rec.endRecording().toImage(w, h);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return MediaStore.instance.putBytes(Uint8List.view(data!.buffer), 'png');
  }

  StickerItem sticker(String id, double x, double y, [double size = 0.26]) =>
      StickerItem(key: Entry.newId(), sticker: id, x: x, y: y, size: size, rotation: (rnd.nextDouble() - 0.5) * 0.5);

  final samples = <(int, Mood, String, String, String?, String?, List<String> Function(), List<StickerItem>, bool)>[
    (0, Mood.calm, tr ? 'Sakin bir sabah' : 'A slow morning', tr ? 'Kahvemi balkonda içtim, şehir daha uyanmamıştı. Bugün kendime biraz zaman ayıracağım.' : 'Had my coffee on the balcony before the city woke up. Today I am taking it slow.', 'lora', null, () => [], [sticker('hot_beverage', 0.78, 0.8, 0.3)], false),
    (1, Mood.great, tr ? 'Doğum günü sürprizi' : 'Birthday surprise', tr ? 'Arkadaşlarım kapıda pastayla bekliyordu! Gece boyunca güldük, en güzel hediye onlardı.' : 'My friends were waiting at the door with a cake! We laughed all night.', 'caveat', 'confetti', () => [], [sticker('party_popper', 0.74, 0.86, 0.3), sticker('birthday_cake', 0.3, 0.96, 0.34)], true),
    (2, Mood.happy, tr ? 'Sahilde gün batımı' : 'Sunset by the sea', tr ? 'Rüzgâr hafifti, gökyüzü pembeye döndü. Telefonumu kapatıp sadece izledim.' : 'Soft wind, pink sky. I turned off my phone and just watched.', null, null, () => ['ocean'], [sticker('sun_with_face', 0.82, 0.78, 0.26)], false),
    (4, Mood.anxious, tr ? 'Sınav haftası' : 'Exam week', tr ? 'Kafamda bir sürü şey var. Listemi küçük parçalara böldüm, yarın ilk ikisini bitireceğim.' : 'So much on my mind. I split my list into small steps; two of them tomorrow.', 'nunito', null, () => [], [], false),
    (5, Mood.loved, tr ? 'Annemle kahve' : 'Coffee with mom', tr ? 'Eski fotoğraflara baktık, çocukluğumdan hikâyeler anlattı. Kalbim ısındı.' : 'We looked at old photos and she told stories from my childhood.', 'dancing', 'peach', () => ['sakura'], [sticker('two_hearts', 0.8, 0.8, 0.26)], true),
    (7, Mood.sad, tr ? 'Yağmurlu bir gün' : 'Rainy day', tr ? 'Bugün biraz buruk hissettim. Sıcak bir çorba ve sevdiğim bir dizi iyi geldi.' : 'Felt a bit low today. Warm soup and a favourite show helped.', null, null, () => [], [sticker('umbrella_with_rain_drops', 0.78, 0.82, 0.3)], false),
    (8, Mood.meh, tr ? 'Sıradan bir salı' : 'An ordinary Tuesday', tr ? 'Ne iyi ne kötü. Akşam yürüyüşü günü kurtardı.' : 'Not good, not bad. The evening walk saved the day.', 'patrick', null, () => [], [], false),
    (10, Mood.calm, tr ? 'Orman yürüyüşü' : 'Forest walk', tr ? 'Çam kokusu, kuş sesleri ve uzun bir sessizlik. Yeniden nefes almışım gibi.' : 'Pine scent, birdsong and a long silence. Like breathing again.', 'lora', 'mint', () => ['forest'], [sticker('herb', 0.18, 0.84, 0.24), sticker('mushroom', 0.84, 0.8, 0.24)], false),
    (12, Mood.angry, tr ? 'Trafik!' : 'Traffic!', tr ? 'Bir saat yolda kaldım. Sonra müzik açtım ve sakinleştim.' : 'Stuck for an hour. Then I put on music and calmed down.', null, null, () => [], [], false),
    (14, Mood.great, tr ? 'Yeni iş!' : 'New job!', tr ? 'Teklifi kabul ettim! Biraz korkutucu ama çok heyecanlıyım.' : 'I accepted the offer! A little scary, mostly exciting.', 'playfair', null, () => [], [sticker('trophy', 0.78, 0.82, 0.3), sticker('sparkles', 0.3, 0.88, 0.22)], true),
    (17, Mood.happy, tr ? 'Kitap kulübü' : 'Book club', tr ? 'Bu ayın kitabını herkes farklı yorumladı, tartışma harikaydı.' : 'Everyone read this month’s book differently; great discussion.', null, null, () => [], [sticker('open_book', 0.8, 0.86, 0.28)], false),
    (21, Mood.calm, tr ? 'Pazar kahvaltısı' : 'Sunday breakfast', tr ? 'Uzun, tembel bir kahvaltı. Bazen en güzel planlar plansız olanlar.' : 'A long, lazy breakfast. The best plans are sometimes no plans.', null, null, () => [], [sticker('croissant', 0.8, 0.8, 0.28)], false),
    (26, Mood.happy, tr ? 'Konser' : 'Concert', tr ? 'Sesim kısıldı ama değdi!' : 'Lost my voice but it was worth it!', null, null, () => [], [sticker('musical_notes', 0.8, 0.8, 0.28)], false),
    (33, Mood.sad, tr ? 'Veda' : 'Goodbye', tr ? 'En yakın arkadaşım başka şehre taşındı.' : 'My best friend moved to another city.', null, null, () => [], [], false),
    (38, Mood.loved, tr ? 'Yıldönümü' : 'Anniversary', tr ? 'Küçük bir kutlama, büyük bir mutluluk.' : 'A small celebration, a big happiness.', null, null, () => [], [sticker('rose', 0.8, 0.8, 0.28)], false),
  ];

  final list = <Entry>[];
  for (final (daysAgo, mood, title, body, font, paper, photosOf, stickers, fav) in samples) {
    final day = now.subtract(Duration(days: daysAgo));
    final date = DateTime(day.year, day.month, day.day, daysAgo == 0 ? now.hour : 20 + daysAgo % 3, (daysAgo * 7) % 60);
    final photos = [for (final t in photosOf()) await photo(t)];
    list.add(Entry(
      id: Entry.newId(),
      date: date,
      mood: mood,
      title: title,
      body: body,
      fontId: font,
      paperId: paper,
      favorite: fav,
      photos: photos,
      audios: daysAgo == 17
          ? [AudioClip(file: 'demo', durationMs: 23000, wave: List.generate(48, (_) => 0.15 + rnd.nextDouble() * 0.85))]
          : const [],
      stickers: stickers,
      createdAt: date,
      updatedAt: date,
    ));
  }
  await entries.merge(list);
}
