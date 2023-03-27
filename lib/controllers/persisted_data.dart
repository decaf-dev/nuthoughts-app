import 'dart:async';
import 'package:nuthoughts/models/thought.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class PersistedData {
  static Database? database;

  static Future<void> openDatabases() async {
    database = await openDatabase(
      join(await getDatabasesPath(), 'recent_thoughts.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE thoughts(id INTEGER PRIMARY KEY, text TEXT, creationTime INTEGER, serverSaveTime INTEGER)',
        );
      },
      version: 1,
    );
  }

  static Future<void> insertThought(Thought thought) async {
    if (database == null) {
      throw Exception("Cannot insert thought. Database is not open.");
    }
    await database!.insert(
      'thoughts',
      thought.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // A method that retrieves all the dogs from the dogs table.
  static Future<List<Thought>> listThoughts() async {
    if (database == null) {
      throw Exception("Cannot list thoughts. Database is not open.");
    }
    final List<Map<String, dynamic>> maps = await database!.query('thoughts');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return Thought(
        id: maps[i]['id'],
        creationTime: maps[i]['creationTime'],
        text: maps[i]['text'],
      );
    });
  }

  static Future<void> deleteThought(int id) async {
    if (database == null) {
      throw Exception("Cannot delete thought. Database is not open.");
    }
    await database!.delete(
      'thoughts',
      where: 'id = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }
}
