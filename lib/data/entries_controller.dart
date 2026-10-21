import 'package:flutter/foundation.dart';

import '../core/format.dart';
import 'entry.dart';
import 'entry_store.dart';
import 'media_store.dart';
import 'mood.dart';

/// All entries are kept in memory (a diary stays small) and written through to the store.
class EntriesController extends ChangeNotifier {
  EntriesController(this._store);
  final EntryStore _store;

  List<Entry> _entries = const [];
  Map<int, List<Entry>> _byDay = const {};
  bool loaded = false;

  /// Newest first.
  List<Entry> get entries => _entries;

  Future<void> load() async {
    _set(await _store.loadAll());
    loaded = true;
    notifyListeners();
  }

  void _set(Iterable<Entry> list) {
    final sorted = list.toList()..sort((a, b) => b.date.compareTo(a.date));
    _entries = List.unmodifiable(sorted);
    final byDay = <int, List<Entry>>{};
    for (final e in sorted) {
      (byDay[dayKey(e.date)] ??= []).add(e);
    }
    _byDay = byDay;
  }

  Entry? byId(String id) => _entries.where((e) => e.id == id).firstOrNull;

  Future<void> save(Entry e) async {
    final updated = e.copyWith(updatedAt: DateTime.now());
    await _store.put(updated);
    _set([..._entries.where((x) => x.id != e.id), updated]);
    notifyListeners();
  }

  Future<void> delete(Entry e) async {
    await _store.delete(e.id);
    await MediaStore.instance.deleteAll([...e.photos, ...e.audios.map((a) => a.file)]);
    _set(_entries.where((x) => x.id != e.id));
    notifyListeners();
  }

  /// Inserts or replaces entries (backup restore).
  Future<void> merge(List<Entry> incoming) async {
    await _store.putAll(incoming);
    final ids = incoming.map((e) => e.id).toSet();
    _set([..._entries.where((e) => !ids.contains(e.id)), ...incoming]);
    notifyListeners();
  }

  Future<void> toggleFavorite(Entry e) => save(e.copyWith(favorite: !e.favorite));

  List<Entry> forDay(DateTime d) => _byDay[dayKey(d)] ?? const [];

  bool hasEntryOn(DateTime d) => _byDay.containsKey(dayKey(d));

  /// Mood shown for a day: the mood of the latest entry that has one.
  Mood? moodOn(DateTime d) => forDay(d).map((e) => e.mood).nonNulls.firstOrNull;

  List<Entry> search(String query, {bool favoritesOnly = false, Mood? mood}) {
    final q = foldText(query.trim());
    return _entries.where((e) {
      if (favoritesOnly && !e.favorite) return false;
      if (mood != null && e.mood != mood) return false;
      if (q.isEmpty) return true;
      return foldText(e.title).contains(q) || foldText(e.body).contains(q);
    }).toList();
  }

  List<Entry> inRange(DateTime from, DateTime to) =>
      _entries.where((e) => !e.date.isBefore(from) && e.date.isBefore(to)).toList();

  /// Consecutive days with an entry, ending today (or yesterday if today is still empty).
  int get currentStreak {
    var day = dateOnly(DateTime.now());
    if (!hasEntryOn(day)) day = day.subtract(const Duration(days: 1));
    var n = 0;
    while (hasEntryOn(day)) {
      n++;
      day = DateTime(day.year, day.month, day.day - 1);
    }
    return n;
  }

  int get longestStreak {
    final days = _byDay.keys.toList()..sort();
    var best = 0, run = 0;
    DateTime? prev;
    for (final k in days) {
      final d = DateTime(k ~/ 10000, k ~/ 100 % 100, k % 100);
      run = (prev != null && DateTime(prev.year, prev.month, prev.day + 1) == d) ? run + 1 : 1;
      if (run > best) best = run;
      prev = d;
    }
    return best;
  }

  int get totalWords => _entries.fold(0, (n, e) => n + wordCount(e.title) + wordCount(e.body));
  int get photoCount => _entries.fold(0, (n, e) => n + e.photos.length);
  int get voiceCount => _entries.fold(0, (n, e) => n + e.audios.length);

  Map<Mood, int> moodCounts(Iterable<Entry> list) {
    final m = {for (final mood in Mood.values) mood: 0};
    for (final e in list) {
      if (e.mood != null) m[e.mood!] = m[e.mood!]! + 1;
    }
    return m;
  }
}
