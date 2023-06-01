import 'dart:async';
import 'package:nuthoughts/models/thought.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SavedData {
  static Database? database;

  ///Opens the database
  ///Must be called before any other methods
  ///The max text size of a thought is 64kb
  static Future<void> initializeDatabase() async {
    database = await openDatabase(
      join(await getDatabasesPath(), 'thoughts.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE thoughts(id INTEGER PRIMARY KEY, text TEXT, creationTime INTEGER, serverSaveTime INTEGER)',
        );
      },
      version: 1,
    );
  }

  static Future<int> insertThought(Thought thought) async {
    final Database? database = SavedData.database;
    if (database == null) {
      throw Exception("Cannot insert thought. Database is not open.");
    }

    return await database.insert(
      'thoughts',
      thought.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> updateThought(Thought thought) async {
    final Database? database = SavedData.database;

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

  static Future<List<Thought>> listThoughts() async {
    final Database? database = SavedData.database;

    if (database == null) {
      throw Exception("Cannot list thoughts. Database is not open.");
    }

    final List<Map<String, dynamic>> maps = await database.query('thoughts');

    return List.generate(maps.length, (i) {
      return Thought(maps[i]['id'], maps[i]['text'],
          creationTime: maps[i]['creationTime'],
          serverSaveTime: maps[i]['serverSaveTime']);
    });
  }

  static Future<void> deleteThought(int id) async {
    final Database? database = SavedData.database;
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
}
