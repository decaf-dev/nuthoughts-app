import 'dart:async';
import 'dart:typed_data';

import 'package:nuthoughts/models/thought.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/history_log_item.dart';

class PersistedStorage {
  static Database? database;

  ///Opens the database
  ///Must be called before any other methods
  ///The max text size of a thought is 64kb
  static Future<void> initDB() async {
    database = await openDatabase(
      join(await getDatabasesPath(), 'nuthoughts.db'),
      onCreate: (db, version) {
        db.execute(
          'CREATE TABLE thoughts(id INTEGER PRIMARY KEY AUTOINCREMENT, text TEXT, creationTime INTEGER, serverSaveTime INTEGER)',
        );

        db.execute(
          'CREATE TABLE certificateAuthority(id INTEGER PRIMARY KEY, value BLOB)',
        );

        db.execute(
          'CREATE TABLE history_log(id INTEGER PRIMARY KEY AUTOINCREMENT, creationTime INTEGER, eventType TEXT, payload TEXT)',
        );
      },
      version: 1,
    );
  }

  static Future<void> insertCertificateAuthority(List<int> value) async {
    final Database? database = PersistedStorage.database;
    if (database == null) {
      throw Exception(
          "Cannot insert certificate authority. Database is not open.");
    }

    await database.insert(
      'certificateAuthority',
      {
        'id': 0,
        'value': value,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<Uint8List?> getCertificateAuthority() async {
    final Database? database = PersistedStorage.database;
    if (database == null) {
      throw Exception(
          "Cannot get certificate authority. Database is not open.");
    }

    List<Map<String, dynamic>> maps =
        await database.query('certificateAuthority');

    if (maps.isEmpty) {
      return null;
    }

    return maps[0]['value'];
  }

  static Future<int> insertThought(Thought thought) async {
    final Database? database = PersistedStorage.database;
    if (database == null) {
      throw Exception("Cannot insert thought. Database is not open.");
    }

    int id = await database.insert(
      'thoughts',
      thought.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  static Future<void> updateThought(Thought thought) async {
    final Database? database = PersistedStorage.database;

    if (database == null) {
      throw Exception("Cannot update thought. Database is not open.");
    }

    await database.update(
      'thoughts',
      thought.toMap(),
      where: 'id = ?',
      // Prevent SQL injection by using whereArgs
      whereArgs: [thought.id],
    );
  }

  static Future<List<Thought>> getThoughts() async {
    final Database? database = PersistedStorage.database;

    if (database == null) {
      throw Exception("Cannot list thoughts. Database is not open.");
    }

    final List<Map<String, dynamic>> maps = await database.query('thoughts');

    return List.generate(maps.length, (i) {
      return Thought.fromDatabase(maps[i]);
    });
  }

  static Future<void> deleteThought(int id) async {
    final Database? database = PersistedStorage.database;
    if (database == null) {
      throw Exception("Cannot delete thought. Database is not open.");
    }

    await database.delete(
      'thoughts',
      where: 'id = ?',
      // Prevent SQL injection by using whereArgs
      whereArgs: [id],
    );
  }

  static Future<int> insertHistoryItem(HistoryLogItem item) async {
    final Database? database = PersistedStorage.database;
    if (database == null) {
      throw Exception("Cannot insert history item. Database is not open.");
    }

    int id = await database.insert(
      'history_log',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  static Future<List<HistoryLogItem>> getHistoryLog() async {
    final Database? database = PersistedStorage.database;

    if (database == null) {
      throw Exception("Cannot list history items. Database is not open.");
    }

    final List<Map<String, dynamic>> maps = await database.query('history_log');

    return List.generate(maps.length, (i) {
      return HistoryLogItem.fromDatabase(maps[i]);
    });
  }
}
