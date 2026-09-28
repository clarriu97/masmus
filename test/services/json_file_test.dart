import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:masmus/services/json_file.dart';

void main() {
  late Directory directory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('json_file_test_');
  });

  tearDown(() => directory.delete(recursive: true));

  File file() => File('${directory.path}/thing.json');

  test('nothing there reads as null; what is written reads back', () async {
    final json = JsonFile.at(file());
    expect(await json.read(), isNull);
    await json.write({'a': 1});
    expect(await JsonFile.at(file()).read(), {'a': 1});
    expect(File('${file().path}.tmp').existsSync(), isFalse);
  });

  test('writes asked one after another land in that order', () async {
    final json = JsonFile.at(file());
    await Future.wait([
      for (var i = 0; i < 5; i++) json.write({'n': i}),
    ]);
    expect(await JsonFile.at(file()).read(), {'n': 4});
  });

  test('something that is not a JSON object throws', () async {
    file().writeAsStringSync('[1, 2]');
    await expectLater(JsonFile.at(file()).read(), throwsFormatException);
  });

  test('setting it aside keeps it with its time', () async {
    file().writeAsStringSync('{"broken"');
    await JsonFile.at(file()).setAside();
    expect(file().existsSync(), isFalse);
    final aside = directory.listSync().whereType<File>().single;
    expect(aside.path, contains('thing.unreadable-'));
    expect(aside.readAsStringSync(), '{"broken"');
  });

  test('deleting removes it', () async {
    final json = JsonFile.at(file());
    await json.write({'a': 1});
    await json.delete();
    expect(file().existsSync(), isFalse);
    expect(await json.read(), isNull);
  });

  test('in memory it behaves the same', () async {
    final json = JsonFile.inMemory({'a': 1});
    expect(await json.read(), {'a': 1});
    await json.write({'b': 2});
    expect(await json.read(), {'b': 2});
    await json.delete();
    expect(await json.read(), isNull);
  });
}
