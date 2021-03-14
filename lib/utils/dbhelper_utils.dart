part of 'utils.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper; // Singleton DatabaseHelper
  static Database _database; // Singleton Database

  String notesTable = 'notes_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'body';
  String colDate = 'date';

  DatabaseHelper._createInstance(); // Named constructor to create instance of DatabaseHelper

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper
          ._createInstance(); // This is executed only once, singleton object
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    // Get the directory path for both Android and iOS to store database.
    io.Directory directory =
        await getApplicationDocumentsDirectory(); //io.Directory itu dari import as .io
    String path = directory.path + 'notes_database';

    // Open/create the database at a given path
    var notesDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    print('create database line 39');
    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $notesTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, '
        '$colDescription TEXT, $colDate TEXT)');
    print('create database line 46');
  }

  // Fetch Operation: Get all note objects from database
  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await this.database;

    //var result = await db.rawQuery('SELECT * FROM $noteTable order by $colPriority ASC');
    var result = await db.query(notesTable, orderBy: '$colId DESC');
    return result;
  }

  Future<List<MyNotes>> getNoteList() async {
    var noteMapList = await getNoteMapList(); // Get 'Map List' from database
    int count =
        noteMapList.length; // Count the number of map entries in db table

    List<MyNotes> noteList = List<MyNotes>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      noteList.add(MyNotes.map(noteMapList[i]));
    }

    return noteList;
  }

  // Insert Operation: Insert a Note object to database
  Future<int> insertNote(MyNotes note) async {
    Database db = await this.database;
    var result = await db.insert(notesTable, note.toMap());
    print('insert note');
    return result;
  }

  // Update Operation: Update a Note object and save it to database
  Future<int> updateNote(MyNotes note) async {
    var db = await this.database;
    var result = await db.update(notesTable, note.toMap(),
        where: '$colId = ?', whereArgs: [note.id]);
    return result;
  }

  // Delete Operation: Delete a Note object from database
  Future<int> deleteNote(int id) async {
    var db = await this.database;
    int result =
        await db.rawDelete('DELETE FROM $notesTable WHERE $colId = $id');
    return result;
  }

  // Get number of Note objects in database
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $notesTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  // Get the 'Map List' [ List<Map> ] and convert it to 'Note List' [ List<Note> ]

  //cek query
  Future<List<Map<String, dynamic>>> queryall() async {
    Database db = await _databaseHelper.database;
    return await db.query("$notesTable");
  }
}

//TODOS INI DBHelper VERSION.1
// class DBHelper {
//   static final DBHelper _instance = DBHelper.internal();
//   DBHelper.internal();

//   factory DBHelper() => _instance;

//   static Database _database; //variabel

//   //Cek database if else data ada, maka if=>statement
//   Future<Database> get database async {
//     if (_database != null) {
//       return _database;
//     } else {
//       _database = await buildDatabase();
//       return _database;
//     }
//   }

//   buildDatabase() async {
//     io.Directory directory = await getApplicationDocumentsDirectory();
//     String path = join(directory.path, "MyNotesDatabase"); //Nama database
//     var dB = await openDatabase(path, version: 1, onCreate: _onCreate);
//     return dB;
//   }

//   //membuat database
//   void _onCreate(Database db, int version) async {
//     await db.execute(
//         "CREATE TABLE MyNotesTable(id INTEGER PRIMARY KEY, title TEXT, body TEXT, createDate TEXT)");
//     print('database created');
//   }

//   //cek query
//   Future<List<Map<String, dynamic>>> queryall() async {
//     Database db = await _instance.database;
//     return await db.query("MyNotesTable");
//   }

//   // Get number of Note objects in database
//   Future<int> getCount() async {
//     var dbClient = await database;
//     List<Map<String, dynamic>> x =
//         await dbClient.rawQuery('SELECT COUNT (*) FROM MyNotesTable');
//     int result = Sqflite.firstIntValue(x);
//     return result;
//   }

//   // delete table
//   // Future<List<Map<String, dynamic>>> deleteTable() async {
//   //   Database db = await _instance.database;
//   //   return await db.rawQuery("DROP TABLE MyNotesTable");
//   // }

//   //simpan notes
//   Future<int> saveNotes(MyNotes myNotes) async {
//     var dbClient = await database;
//     int res = await dbClient.insert("MyNotesTable", myNotes.toMap());
//     print('data ditambahkan');
//     return res;
//   }

//   //get notes
//   Future<List<MyNotes>> getNotes() async {
//     var dbClient = await database;
//     List<Map> list =
//         await dbClient.rawQuery("SELECT * FROM MyNotesTable ORDER BY id DESC");
//     //listnya di pecah
//     List<MyNotes> notedata = List();
//     for (int i = 0; i < list.length; i++) {
//       var note = MyNotes(
//           titleModels: list[i]['title'],
//           bodyModels: list[i]['body'],
//           createDateModels: list[i]['createDate']);
//       note.setNotesId(list[i]['id']);
//       notedata.add(note);
//     }
//     return notedata;
//   }

//   //update notes
//   Future<bool> updateNotes(MyNotes notes) async {
//     var dbClient = await database;
//     int res = await dbClient.update("MyNotesTable", notes.toMap(),
//         where: "id=?", whereArgs: <int>[notes.idModels]);
//     return res > 0 ? true : false;
//   }

//   //delete notes
//   Future<int> deleteNotes(MyNotes notes) async {
//     var dbClient = await database;
//     int result = await dbClient
//         .rawDelete("DELETE FROM MyNotesTable WHERE id= ?", [notes.idModels]);
//     return result;
//   }
// }
