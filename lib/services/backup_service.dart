import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/entries_controller.dart';
import '../data/entry.dart';
import '../data/media_store.dart';

/// Manual backup: one .zip with every entry and its photos/voice notes. The user
/// keeps it wherever they like (Drive, e-mail, files) through the share sheet.
abstract final class BackupService {
  static Future<void> export(EntriesController entries, {required String shareText}) async {
    final archive = Archive();
    archive.addFile(ArchiveFile.string(
      'entries.json',
      jsonEncode({
        'app': 'gunce',
        'format': 1,
        'exported': DateTime.now().toIso8601String(),
        'entries': [for (final e in entries.entries) e.toJson()],
      }),
    ));
    final media = MediaStore.instance;
    for (final e in entries.entries) {
      for (final name in [...e.photos, ...e.audios.map((a) => a.file)]) {
        final f = File(p.join(media.dir.path, name));
        if (await f.exists()) archive.addFile(ArchiveFile.bytes('media/$name', await f.readAsBytes()));
      }
    }
    final tmp = await getTemporaryDirectory();
    final out = File(p.join(tmp.path, 'gunce-${DateFormat('yyyy-MM-dd').format(DateTime.now())}.zip'));
    await out.writeAsBytes(ZipEncoder().encodeBytes(archive));
    await SharePlus.instance.share(ShareParams(files: [XFile(out.path, mimeType: 'application/zip')], text: shareText));
  }

  /// Returns the number of restored entries, or null if the user cancelled.
  /// Throws [FormatException] for files that are not Günce backups.
  static Future<int?> import(EntriesController entries) async {
    final picked = await FilePicker.pickFiles(type: FileType.any);
    final path = picked.isEmpty ? null : picked.first.path;
    if (path == null) return null;
    final archive = ZipDecoder().decodeBytes(await File(path).readAsBytes());
    final index = archive.findFile('entries.json');
    if (index == null) throw const FormatException('not a backup');
    final data = jsonDecode(utf8.decode(index.content)) as Map<String, Object?>;
    if (data['app'] != 'gunce') throw const FormatException('not a backup');

    final mediaDir = MediaStore.instance.dir.path;
    for (final f in archive.files) {
      if (!f.isFile || !f.name.startsWith('media/')) continue;
      final name = p.basename(f.name);
      final target = File(p.join(mediaDir, name));
      if (!await target.exists()) await target.writeAsBytes(f.content);
    }
    final list = [for (final e in data['entries'] as List) Entry.fromJson((e as Map).cast())];
    await entries.merge(list);
    return list.length;
  }
}
