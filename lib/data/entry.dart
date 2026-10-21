import 'dart:math' as math;

import 'mood.dart';

/// One diary page. Stored as JSON so new fields can be added without migrations.
class Entry {
  Entry({
    required this.id,
    required this.date,
    this.mood,
    this.title = '',
    this.body = '',
    this.fontId,
    this.inkColor,
    this.paperId,
    this.favorite = false,
    this.photos = const [],
    this.audios = const [],
    this.stickers = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Entry.create(DateTime date, {Mood? mood}) {
    final now = DateTime.now();
    return Entry(id: newId(), date: date, mood: mood, createdAt: now, updatedAt: now);
  }

  final String id;
  final DateTime date;
  final Mood? mood;
  final String title;
  final String body;
  final String? fontId;
  final int? inkColor;
  final String? paperId;
  final bool favorite;

  /// Media file names inside the app media folder (see MediaStore).
  final List<String> photos;
  final List<AudioClip> audios;
  final List<StickerItem> stickers;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isEmpty => title.trim().isEmpty && body.trim().isEmpty && photos.isEmpty && audios.isEmpty && stickers.isEmpty && mood == null;

  Entry copyWith({
    DateTime? date,
    Mood? mood,
    bool clearMood = false,
    String? title,
    String? body,
    String? fontId,
    int? inkColor,
    bool clearInk = false,
    String? paperId,
    bool? favorite,
    List<String>? photos,
    List<AudioClip>? audios,
    List<StickerItem>? stickers,
    DateTime? updatedAt,
  }) =>
      Entry(
        id: id,
        date: date ?? this.date,
        mood: clearMood ? null : (mood ?? this.mood),
        title: title ?? this.title,
        body: body ?? this.body,
        fontId: fontId ?? this.fontId,
        inkColor: clearInk ? null : (inkColor ?? this.inkColor),
        paperId: paperId ?? this.paperId,
        favorite: favorite ?? this.favorite,
        photos: photos ?? this.photos,
        audios: audios ?? this.audios,
        stickers: stickers ?? this.stickers,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, Object?> toJson() => {
        'v': 1,
        'id': id,
        'date': date.toIso8601String(),
        'mood': mood?.name,
        'title': title,
        'body': body,
        'font': fontId,
        'ink': inkColor,
        'paper': paperId,
        'fav': favorite,
        'photos': photos,
        'audios': [for (final a in audios) a.toJson()],
        'stickers': [for (final s in stickers) s.toJson()],
        'created': createdAt.toIso8601String(),
        'updated': updatedAt.toIso8601String(),
      };

  factory Entry.fromJson(Map<String, Object?> j) => Entry(
        id: j['id'] as String,
        date: DateTime.parse(j['date'] as String),
        mood: Mood.byName(j['mood'] as String?),
        title: (j['title'] as String?) ?? '',
        body: (j['body'] as String?) ?? '',
        fontId: j['font'] as String?,
        inkColor: j['ink'] as int?,
        paperId: j['paper'] as String?,
        favorite: (j['fav'] as bool?) ?? false,
        photos: [for (final p in (j['photos'] as List?) ?? const []) p as String],
        audios: [for (final a in (j['audios'] as List?) ?? const []) AudioClip.fromJson((a as Map).cast())],
        stickers: [for (final s in (j['stickers'] as List?) ?? const []) StickerItem.fromJson((s as Map).cast())],
        createdAt: DateTime.parse(j['created'] as String),
        updatedAt: DateTime.parse(j['updated'] as String),
      );

  static final _rnd = math.Random();
  static String newId() =>
      '${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}${_rnd.nextInt(1 << 30).toRadixString(36)}';
}

class AudioClip {
  const AudioClip({required this.file, required this.durationMs, this.wave = const []});

  final String file;
  final int durationMs;

  /// Normalised (0..1) loudness samples recorded while capturing, for the waveform.
  final List<double> wave;

  Map<String, Object?> toJson() => {'file': file, 'ms': durationMs, 'wave': [for (final w in wave) (w * 100).round()]};

  factory AudioClip.fromJson(Map<String, Object?> j) => AudioClip(
        file: j['file'] as String,
        durationMs: (j['ms'] as num).toInt(),
        wave: [for (final w in (j['wave'] as List?) ?? const []) (w as num) / 100],
      );
}

/// A sticker placed on a page. Position and size are fractions of the page
/// width, so a page looks the same on every screen size.
class StickerItem {
  const StickerItem({required this.key, required this.sticker, required this.x, required this.y, this.size = 0.28, this.rotation = 0});

  final String key;
  final String sticker;
  final double x, y, size, rotation;

  StickerItem copyWith({double? x, double? y, double? size, double? rotation}) => StickerItem(
        key: key,
        sticker: sticker,
        x: x ?? this.x,
        y: y ?? this.y,
        size: size ?? this.size,
        rotation: rotation ?? this.rotation,
      );

  Map<String, Object?> toJson() => {'k': key, 's': sticker, 'x': x, 'y': y, 'size': size, 'r': rotation};

  factory StickerItem.fromJson(Map<String, Object?> j) => StickerItem(
        key: j['k'] as String,
        sticker: j['s'] as String,
        x: (j['x'] as num).toDouble(),
        y: (j['y'] as num).toDouble(),
        size: (j['size'] as num).toDouble(),
        rotation: (j['r'] as num).toDouble(),
      );
}
