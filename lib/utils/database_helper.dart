import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:myproject/models/hike.dart';
import 'package:myproject/models/observation.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  static Database? _db;

  DatabaseHelper.internal();

  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  Future<Database> initDb() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, "my_database.db");
    var ourDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return ourDb;
  }

  void _onCreate(Database db, int version) async {
    // Create the 'hike' table
    await db.execute('''
      CREATE TABLE hike (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nameOfHike TEXT,
        lengthOfHike INTEGER,
        levelDifficulty TEXT,
        parkingAvailable INTEGER,
        location TEXT,
        date TEXT,
        description TEXT
      )
    ''');

    // Create the 'observation' table
    await db.execute('''
      CREATE TABLE observation (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT,
        date TEXT,
        comment TEXT,
        hikeId INTEGER,
        FOREIGN KEY (hikeId) REFERENCES hike (id)
      )
    ''');
  }

  // HikeData methods

  Future<int> insertHike(Hike hike) async {
    var dbClient = await db;
    int res = await dbClient!.insert("hike", hike.toMap());
    return res;
  }

  Future<List<Hike>>  getHikes() async {
    final dbClient= await db;
    var result = await dbClient?.query('hike');

    List<Hike> hikes = [];
    if(result != null) {
      for (var hikeMap in result) {
        hikes.add(mapToHike(hikeMap));
      }
    }

    return hikes;
  }

  Hike mapToHike(Map<String, dynamic> hikeMap) {
    return Hike.WithId(
      hikeMap['id'],
      hikeMap['nameOfHike'],
      hikeMap['lengthOfHike'],
      hikeMap['levelDifficulty'],
      hikeMap['parkingAvailable'] == 1,
      hikeMap['location'],
      hikeMap['date'],
      hikeMap['description'],
    );
  }
  // Add other methods for HikeData CRUD operations

  // ObservationData methods

  Future<int> insertObservation(Observation observation) async {
    var dbClient = await db;
    int res = await dbClient!.insert("observation", observation.toMap());
    return res;
  }

  Future<List<Map<String, dynamic>>> getObservations() async {
    var dbClient = await db;
    var result = await dbClient!.query("observation");
    return result;
  }



  // HikeData CRUD operations

  Future<int> updateHike(Hike hike) async {
    var dbClient = await db;
    return await dbClient!.update("hike", hike.toMap(),
        where: "id = ?", whereArgs: [hike.id]);
  }

  Future<int> deleteHike(int id) async {
    var dbClient = await db;
    return await dbClient!.delete("hike", where: "id = ?", whereArgs: [id]);
  }

  // ObservationData CRUD operations

  Future<int> updateObservation(Observation observation) async {
    var dbClient = await db;
    return await dbClient!.update("observation", observation.toMap(),
        where: "id = ?", whereArgs: [observation.id]);
  }

  Future<int> deleteObservation(int id) async {
    var dbClient = await db;
    return await dbClient!
        .delete("observation", where: "id = ?", whereArgs: [id]);
  }

  // Search functionality

  Future<List<Map<String, dynamic>>> searchHikes(String searchTerm) async {
    var dbClient = await db;
    return await dbClient!.query("hike",
        where: "nameOfHike LIKE ? OR location LIKE ?",
        whereArgs: ['%$searchTerm%', '%$searchTerm%']);
  }

  Future<List<Map<String, dynamic>>> searchObservations(String searchTerm) async {
    var dbClient = await db;
    return await dbClient!.query("observation",
        where: "type LIKE ? OR comment LIKE ?",
        whereArgs: ['%$searchTerm%', '%$searchTerm%']);
  }
  Future<List<Observation>> getObservationsByHikeId(int hikeId) async {
    final dbClient = await db;
    var result = await dbClient!.query(
      'observation',
      where: 'hikeId = ?',
      whereArgs: [hikeId],
    );

    List<Observation> observations = [];
    if (result != null) {
      for (var observationMap in result) {
        observations.add(mapToObservation(observationMap));
      }
    }

    return observations;
  }

  Observation mapToObservation(Map<String, dynamic> observationMap) {
    return Observation.WithId(
      observationMap['id'],
      observationMap['type'],
      observationMap['date'],
      observationMap['comment'],
      observationMap['hikeId'],
    );
  }




}
