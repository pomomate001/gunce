import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'entry.dart';

/// Photos and voice notes live in `<app documents>/media`. Entries only keep file names.
class MediaStore {
  MediaStore._();
  static final instance = MediaStore._();

  Directory? _dir;
  final _web = <String, Uint8List>{};

  Future<void> init() async {
    if (kIsWeb) return;
    final docs = await getApplicationDocumentsDirectory();
    _dir = Directory(p.join(docs.path, 'media'));
    await _dir!.create(recursive: true);
  }

  Directory get dir => _dir!;

  String _newName(String prefix, String ext) => '${prefix}_${Entry.newId()}.$ext';

  Future<String> importPhoto(XFile file) async {
    var ext = p.extension(file.name).replaceFirst('.', '').toLowerCase();
    if (ext.isEmpty || ext.length > 5) ext = 'jpg';
    final name = _newName('p', ext);
    if (kIsWeb) {
      _web[name] = await file.readAsBytes();
    } else {
      await file.saveTo(p.join(dir.path, name));
    }
    return name;
  }

  /// Demo data only (web preview and screenshot builds).
  Future<String> putBytes(Uint8List bytes, String ext) async {
    final name = _newName('p', ext);
    if (kIsWeb) {
      _web[name] = bytes;
    } else {
      await File(p.join(dir.path, name)).writeAsBytes(bytes);
    }
    return name;
  }

  Future<String> tempAudioPath() async {
    if (kIsWeb) return '';
    final tmp = await getTemporaryDirectory();
    return p.join(tmp.path, 'rec_${Entry.newId()}.m4a');
  }

  /// Moves a finished recording into the media folder.
  Future<String> importAudio(String recordedPath) async {
    if (kIsWeb) return recordedPath;
    final name = _newName('a', 'm4a');
    final src = File(recordedPath);
    await src.copy(p.join(dir.path, name));
    await src.delete();
    return name;
  }

  ImageProvider photo(String name) {
    if (kIsWeb) return MemoryImage(_web[name] ?? _transparentPixel);
    return FileImage(File(p.join(dir.path, name)));
  }

  String audioSource(String name) => kIsWeb ? name : p.join(dir.path, name);

  bool exists(String name) => kIsWeb ? _web.containsKey(name) : File(p.join(dir.path, name)).existsSync();

  Future<void> delete(String name) async {
    if (kIsWeb) {
      _web.remove(name);
      return;
    }
    final f = File(p.join(dir.path, name));
    if (await f.exists()) await f.delete();
  }

  Future<void> deleteAll(Iterable<String> names) async {
    for (final n in names) {
      await delete(n);
    }
  }
}

final _transparentPixel = Uint8List.fromList(const [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, //
  0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);
