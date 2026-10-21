import 'package:flutter_test/flutter_test.dart';
import 'package:gunce/core/format.dart';
import 'package:gunce/data/entries_controller.dart';
import 'package:gunce/data/entry.dart';
import 'package:gunce/data/entry_store.dart';
import 'package:gunce/data/mood.dart';
import 'package:gunce/services/lock_service.dart';

Entry _entry(DateTime date, {Mood? mood, String title = 'x', String body = ''}) =>
    Entry.create(date, mood: mood).copyWith(title: title, body: body);

void main() {
  group('foldText', () {
    test('matches Turkish text without diacritics or case', () {
      expect(foldText('Günlüğüm İSTANBUL Şeker Çiçek'), 'gunlugum istanbul seker cicek');
      expect(foldText('IŞIK'), 'isik');
    });

    test('keeps the length so search highlights line up', () {
      const s = 'Bugün Ilık bir gün';
      expect(foldText(s).length, s.length);
    });
  });

  test('entry survives a JSON round trip', () {
    final e = _entry(DateTime(2026, 10, 21, 14, 5), mood: Mood.calm, title: 'Sakin bir gün', body: 'Parka gittik').copyWith(
      photos: ['p_1.jpg'],
      audios: [const AudioClip(file: 'a_1.m4a', durationMs: 3000, wave: [0.1, 0.5, 1])],
      stickers: [const StickerItem(key: 'k', sticker: 'red_heart', x: 0.5, y: 0.7, size: 0.3, rotation: 0.2)],
      favorite: true,
      paperId: 'lined',
      fontId: 'caveat',
      inkColor: 0xFF2F3A56,
    );
    final back = Entry.fromJson(e.toJson());
    expect(back.toJson(), e.toJson());
    expect(back.audios.single.wave, [0.1, 0.5, 1]);
  });

  test('empty entry detection', () {
    expect(Entry.create(DateTime.now()).isEmpty, isTrue);
    expect(Entry.create(DateTime.now(), mood: Mood.happy).isEmpty, isFalse);
  });

  group('EntriesController', () {
    late EntriesController c;
    setUp(() async {
      c = EntriesController(MemoryEntryStore());
      await c.load();
    });

    test('streaks count consecutive days up to today', () async {
      final today = dateOnly(DateTime.now());
      for (final d in [0, 1, 2, 5, 6, 7, 8]) {
        await c.save(_entry(today.subtract(Duration(days: d)).add(const Duration(hours: 9))));
      }
      expect(c.currentStreak, 3);
      expect(c.longestStreak, 4);
    });

    test('streak still counts when today is not written yet', () async {
      final today = dateOnly(DateTime.now());
      await c.save(_entry(today.subtract(const Duration(days: 1)).add(const Duration(hours: 9))));
      await c.save(_entry(today.subtract(const Duration(days: 2)).add(const Duration(hours: 9))));
      expect(c.currentStreak, 2);
    });

    test('search ignores case and Turkish diacritics, filters by mood', () async {
      await c.save(_entry(DateTime(2026, 10, 1), mood: Mood.happy, title: 'Günlük Yürüyüş'));
      await c.save(_entry(DateTime(2026, 10, 2), mood: Mood.sad, body: 'yagmur yağdı'));
      expect(c.search('gunluk').length, 1);
      expect(c.search('YAĞMUR').length, 1);
      expect(c.search('', mood: Mood.sad).single.body, 'yagmur yağdı');
    });

    test('mood of a day is the latest entry with a mood', () async {
      await c.save(_entry(DateTime(2026, 10, 3, 9), mood: Mood.sad));
      await c.save(_entry(DateTime(2026, 10, 3, 21), mood: Mood.great));
      await c.save(_entry(DateTime(2026, 10, 3, 22)));
      expect(c.moodOn(DateTime(2026, 10, 3)), Mood.great);
    });
  });

  test('PIN hash depends on salt and never equals the PIN', () {
    final a = LockService.hash('1234', 'salt-a');
    expect(a, isNot(contains('1234')));
    expect(a, LockService.hash('1234', 'salt-a'));
    expect(a, isNot(LockService.hash('1234', 'salt-b')));
  });
}
