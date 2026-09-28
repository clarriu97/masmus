import 'dart:convert';
import 'dart:io';

/// A JSON object kept in a file, written so that a write cut short never
/// leaves half of it, and never overwritten when it couldn't be read.
abstract interface class JsonFile {
  /// In memory, going through JSON text as the file does. For tests.
  factory JsonFile.inMemory([Map<String, Object?>? json]) = _MemoryJsonFile;

  factory JsonFile.at(File file) = _DiskJsonFile;

  /// What is in it, null when there is nothing. Throws [FormatException]
  /// when it can't be read as a JSON object.
  Future<Map<String, Object?>?> read();

  Future<void> write(Map<String, Object?> json);

  Future<void> delete();

  /// Renames it aside, with its time, so what can't be read isn't lost.
  Future<void> setAside();
}

final class _MemoryJsonFile implements JsonFile {
  _MemoryJsonFile([Map<String, Object?>? json])
    : _text = json == null ? null : jsonEncode(json);

  String? _text;

  @override
  Future<Map<String, Object?>?> read() async => switch (_text) {
    final text? => _decode(text),
    null => null,
  };

  @override
  Future<void> write(Map<String, Object?> json) async =>
      _text = jsonEncode(json);

  @override
  Future<void> delete() async => _text = null;

  @override
  Future<void> setAside() async => _text = null;
}

final class _DiskJsonFile implements JsonFile {
  _DiskJsonFile(this._file);

  final File _file;

  File get _temp => File('${_file.path}.tmp');

  /// Writes and deletes one after another, in the order they were asked.
  Future<void> _last = Future.value();

  Future<void> _queue(Future<void> Function() change) =>
      _last = _last.then((_) => change());

  @override
  Future<Map<String, Object?>?> read() async {
    if (!await _file.exists()) {
      return null;
    }
    return _decode(await _file.readAsString());
  }

  /// Writes a temporary file and renames it over the real one.
  @override
  Future<void> write(Map<String, Object?> json) {
    final text = jsonEncode(json);
    return _queue(() async {
      await _temp.writeAsString(text, flush: true);
      await _temp.rename(_file.path);
    });
  }

  @override
  Future<void> delete() => _queue(() async {
    if (await _file.exists()) {
      await _file.delete();
    }
  });

  @override
  Future<void> setAside() => _queue(() async {
    final name = _file.uri.pathSegments.last.replaceAll('.json', '');
    final stamp = DateTime.now().millisecondsSinceEpoch;
    await _file.rename('${_file.parent.path}/$name.unreadable-$stamp.json');
  });
}

Map<String, Object?> _decode(String text) => switch (jsonDecode(text)) {
  final Map<String, Object?> json => json,
  _ => throw const FormatException('Not a JSON object'),
};
