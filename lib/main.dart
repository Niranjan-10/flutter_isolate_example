import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:path/path.dart';

import 'db/db_handler.dart';

void main() {
  runApp(MyApp());
  // _createDBIsolate().then((_) {
  //   print("sending message to db isolate");
  //   _dbSendPort!.send("message from main");
  // });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {



void myFunc(){
  String secret_val  = "07844193dc60d726b46baa8869e655168082f738u7y6tt";
  String token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJtb2JpbGUiOiI5OTcxODczODM3In0.FTh0ULs3oM0iL1LYn-zs_MQAMj8GZ4oz1_qrH0JYnHU";

  final jwt =  verifyJwtHS256Signature(token, secret_val);

  // final decoded = jwt.decode(token);
  print(jwt["mobile"]);
}
  


  @override
  Widget build(BuildContext context) {

    // myFunc();

    return MaterialApp(
      home: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: (){
              _createDBIsolate().then((_) {
                print("sending message to db isolate");
              _dbSendPort!.send("message from main");
              });
          },
        ),
        body: Container(
          child: Center(
            child: ElevatedButton(
              child: Text("Insert Data"),
              onPressed: (){
                Map<String,dynamic> data = {Databasehandler.columnString:"Your data"};
                Databasehandler.instance.insert(data);
              },
            ),
          ),
        ),
      ),
      
    );
  }
}


SendPort? _dbSendPort;
FlutterIsolate? _dbIsolate;

Future<void> _createDBIsolate() async {

  if (_dbIsolate != null) {
    return;
  }

  ReceivePort receivePort = ReceivePort();

  _dbIsolate = await FlutterIsolate.spawn(
    _dbMain,
    receivePort.sendPort,
  );

  _dbSendPort = await receivePort.first;
}


void _dbMain(SendPort callerSendPort) {

  ReceivePort newIsolateReceivePort = ReceivePort();

  callerSendPort.send(newIsolateReceivePort.sendPort);

  newIsolateReceivePort.listen((dynamic message) {
    print("db isolate got message: $message");
    _dbOperation();
  });
}

void _dbOperation() async {
  print("db in an isolate");
  try {
    // var databasesPath = await getDatabasesPath();

    // String path = join(databasesPath, 'demo.db');
    // Database database = await openDatabase(path, version: 1,
    //     onCreate: (Database db, int version) async {
    //       // When creating the db, create the table
    //       await db.execute(
    //           'CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT, value INTEGER, num REAL)');
    //     });

    // Insert some records in a transaction
    // await database.transaction((txn) async {
    //   int id1 = await txn.rawInsert(
    //       'INSERT INTO Test(name, value, num) VALUES("some name", 1234, 456.789)');
    //   print('inserted1: $id1');
    //   int id2 = await txn.rawInsert(
    //       'INSERT INTO Test(name, value, num) VALUES(?, ?, ?)',
    //       ['another name', 12345678, 3.1416]);
    //   print('inserted2: $id2');
    // });
    
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, "MyDb.db");
    Database database = await openDatabase(path,version:1,onCreate:(Database db, int version)async{
      await db.execute('''
    CREATE TABLE ${Databasehandler.table} (
      ${Databasehandler.columnId} INTEGER PRIMARY KEY,
      ${Databasehandler.columnString} TEXT

    );
    ''');
    });

    await database.transaction((txn)async{
        List<Map<String,dynamic>> result = await txn.rawQuery('SELECT * FROM ${Databasehandler.table}');
        print(result);
    });


  } catch (error, stacktrace) {
    print(error);
    print(stacktrace);
  }
}