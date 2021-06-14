import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Databasehandler{

  static final _databaseName = "MyDb.db";
  static final _databaseVersion = 1;

  static final table = 'my_table';
  static final columnId = "_id";
  static final columnString = "string_variable";




  Databasehandler._privateConstructor();

  static final Databasehandler instance = Databasehandler._privateConstructor();

  static Database? _database;

  Future<Database?> get database async{

    if(_database != null){
      return _database;
    }

    _database = await _initDatabase();

    return _database;
  }

  _initDatabase()async{
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, _databaseName);

    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
    
  }

    Future _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE $table (
      $columnId INTEGER PRIMARY KEY,
      $columnString TEXT

    );
    ''');

    }

  Future<int> insert(Map<String, dynamic> row) async {
      Database? db = await instance.database;
      print(row);
    return await db!.insert(table, row, nullColumnHack: columnId);
  }


  Future<List<Map<String,dynamic>>> readData()async{
     Database? db = await instance.database;
    return await db
        !.rawQuery('SELECT * FROM $table');
  }


}