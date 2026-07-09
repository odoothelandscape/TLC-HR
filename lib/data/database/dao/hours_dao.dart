import 'dart:async';
import 'package:sqflite/sqflite.dart';

import '../../models/hours/hours.dart';
import '../db_provider.dart';

class HoursDao {
  //Hours
  final dbProvider = DatabaseProvider.db;

  Future<List<Hours>> getHoursList() async {
    var db = await dbProvider.database;
    var result = await db!.rawQuery("SELECT * FROM hours ORDER BY id DESC");
    List<Hours> list = result.isNotEmpty
        ? result.map((u) => Hours.fromJson(u)).toList()
        : [];
    return list;
  }

    Future<List<Hours>> getHoursListByType(String type) async {
    var db = await dbProvider.database;
    var result = await db!.rawQuery("SELECT * FROM hours WHERE type = '$type' ORDER BY id DESC");
    List<Hours> list = result.isNotEmpty
        ? result.map((u) => Hours.fromJson(u)).toList()
        : [];
    return list;
  }

  Future<Hours> getSingleHoursById(int id) async {
    var db = await dbProvider.database;
    List<Map<String, Object?>> result;
    result = await db!.rawQuery("SELECT * FROM hours WHERE id = $id");

    if (result.isEmpty) {
      throw Exception('Hours not found for id $id');
    }
    Hours hours = Hours.fromJson(Map<String, dynamic>.from(result.first));
   Future<Hours> getSingleHoursByType(String type) async {
    var db = await dbProvider.database;
    List<Map<String, Object?>> result;
    result = await db!.rawQuery("SELECT * FROM hours WHERE type = '$type'");

    if (result.isEmpty) {
      throw Exception('Hours not found for type $type');
    }
    Hours hours = Hours.fromJson(Map<String, dynamic>.from(result.first));
    return hours;
  }
    
    return hours;
  }

  Future insertHours(List<Hours> HoursList) async {

    final db = await dbProvider.database;
    Batch batch = db!.batch();

    for (int i = 0; i < HoursList.length; i++) {
      batch.insert("hours", HoursList[i].toJson());
    }
    await batch.commit(noResult: true);

    return "success";
  }

  insertSingleHours(Hours Hours) async {
    final db = await dbProvider.database;
    final result = await db!.insert("hours", Hours.toJson());
    return result;
  }

  updateHours(Hours Hours) async {
    Database? db = await dbProvider.database;
    final result = await db!.update(
      'hours',
      Hours.toJson(),
      where: "id = ?",
      whereArgs: [Hours.id],
    );
    return result;
  }

  Future<int> deleteHoursRecords() async {
    Database? db = await dbProvider.database;
    var result = db!.rawDelete('Delete from hours');
    return result;
  }
}
