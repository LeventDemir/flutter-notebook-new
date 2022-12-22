import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:notebook/models/note.dart';

class DbHelper {
  String tableName = "Note";
  String colId = "id";
  String columnTitle = "title";
  String columnDescription = "description";
  String columnPhoto = "photo";
  String columnAudio = "audio";
  String columnDate = "date";

  static final DbHelper _dbHelper = DbHelper._internal();

  DbHelper._internal();

  factory DbHelper() {
    return _dbHelper;
  }

  static Database? _db;

  Future<Database?> get db async {
    if (_db == null) {
      _db = await initalizeDb();
    }

    return _db;
  }

  Future<Database> initalizeDb() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + "note.db";

    var dbData = await openDatabase(path, version: 1, onCreate: _createDb);

    return dbData;
  }

  void _createDb(Database db, int version) async {
    await db.execute(
      "Create Table $tableName($colId integer primary key, $columnTitle text, $columnDescription text, $columnPhoto text, $columnAudio text,  $columnDate text)",
    );
  }

  Future<int?> save(Note note) async {
    Database? db = await this.db;
    var result = await db?.insert(tableName, note.toMap());

    return result;
  }

  Future<int?> update(Note note) async {
    Database? db = await this.db;
    var result = await db?.update(
      tableName,
      note.toMap(),
      where: "$colId = ?",
      whereArgs: [note.id],
    );
    return result;
  }

  Future<Future<int>?> remove(int id) async {
    Database? db = await this.db;
    var result = db?.rawDelete("Delete from $tableName where $colId = $id");

    return result;
  }

  Future<List<Map<String, Object?>>?> getNotes() async {
    Database? db = await this.db;
    var result = await db
        ?.rawQuery("Select * from $tableName order by $columnDate DESC");

    return result;
  }
}
