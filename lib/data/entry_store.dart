import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../core/format.dart';
import 'entry.dart';

/// Persists entries on the device. There is no server: the diary never leaves the phone.
abstract class EntryStore {
  Future<List<Entry>> loadAll();
  Future<void> put(Entry e);
  Future<void> putAll(Iterable<Entry> entries);
  Future<void> delete(String id);

  static Future<EntryStore> open() async => kIsWeb ? MemoryEntryStore() : await SqliteEntryStore.open();
}

class SqliteEntryStore implements EntryStore {
  SqliteEntryStore._(this._db);
  final Database _db;

  static Future<SqliteEntryStore> open() async {
    final db = await openDatabase(
      p.join(await getDatabasesPath(), 'gunce.db'),
      version: 1,
      onCreate: (db, _) async {
        await db.execute(
          'CREATE TABLE entries (id TEXT PRIMARY KEY, day INTEGER NOT NULL, updated INTEGER NOT NULL, data TEXT NOT NULL)',
        );
        await db.execute('CREATE INDEX entries_day ON entries(day)');
      },
    );
    return SqliteEntryStore._(db);
  }

  Map<String, Object?> _row(Entry e) => {
        'id': e.id,
        'day': dayKey(e.date),
        'updated': e.updatedAt.millisecondsSinceEpoch,
        'data': jsonEncode(e.toJson()),
      };

  @override
  Future<List<Entry>> loadAll() async {
    final rows = await _db.query('entries', columns: ['data']);
    final out = <Entry>[];
    for (final r in rows) {
      try {
        out.add(Entry.fromJson((jsonDecode(r['data'] as String) as Map).cast()));
      } catch (e) {
        debugPrint('skipping unreadable entry: $e');
      }
    }
    return out;
  }

  @override
  Future<void> put(Entry e) => _db.insert('entries', _row(e), conflictAlgorithm: ConflictAlgorithm.replace);

  @override
  Future<void> putAll(Iterable<Entry> entries) => _db.transaction((txn) async {
        final batch = txn.batch();
        for (final e in entries) {
          batch.insert('entries', _row(e), conflictAlgorithm: ConflictAlgorithm.replace);
        }
        await batch.commit(noResult: true);
      });

  @override
  Future<void> delete(String id) => _db.delete('entries', where: 'id = ?', whereArgs: [id]);
}

/// Used by the web build (design preview only).
class MemoryEntryStore implements EntryStore {
  final _items = <String, Entry>{};

  @override
  Future<List<Entry>> loadAll() async => _items.values.toList();

  @override
  Future<void> put(Entry e) async => _items[e.id] = e;

  @override
  Future<void> putAll(Iterable<Entry> entries) async {
    for (final e in entries) {
      _items[e.id] = e;
    }
  }

  @override
  Future<void> delete(String id) async => _items.remove(id);
}
