import 'dart:io';

import 'package:collector/repo/covid_stats_manager.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();

  static Database? _database;

  Future<Database> get database async {
    // if _database is null we instantiate it
    _database = _database ?? await initDB();
    return Future.value(_database);
  }

  initDB() async {
    String path = join(await getDatabasesPath(), "AppDB.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE CovidStats ("
          "iso TEXT PRIMARY KEY,"
          "country TEXT,"
          "total_confirmed_cases INTEGER,"
          "newly_confirmed_cases INTEGER,"
          "total_deaths INTEGER,"
          "new_deaths INTEGER,"
          "total_recovered_cases INTEGER,"
          "newly_recovered_cases INTEGER"
          ")");
    });
  }

  insertStats(CovidStatsModel covidStatsModel) async {
    final db = await database;
    var res = await db.insert(
      "CovidStats",
      covidStatsModel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return res;
  }

  deleteStats(String iso) async {
    final db = await database;
    db.delete("CovidStats", where: "iso = ?", whereArgs: [iso]);
  }

  Future<List<CovidStatsModel>> covidStatsList({required String country}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps;
    if (country.trim().isEmpty) {
      maps = await db.query('CovidStats');
    } else {
      maps = await db
          .query('CovidStats', where: "country LIKE '%$country%'");
    }

    return List.generate(maps.length, (i) {
      return CovidStatsModel(
          totalConfirmedCases: maps[i]['total_confirmed_cases'],
          newlyConfirmedCases: maps[i]['newly_confirmed_cases'],
          totalDeaths: maps[i]['total_deaths'],
          newDeaths: maps[i]['new_deaths'],
          totalRecoveredCases: maps[i]['total_recovered_cases'],
          newlyRecoveredCases: maps[i]['newly_recovered_cases'],
          isoCode: maps[i]['iso'],
          country: maps[i]['country']);
    }).reversed.toList();
  }
}
