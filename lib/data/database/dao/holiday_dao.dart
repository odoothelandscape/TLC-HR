import 'dart:async';
import 'package:sqflite/sqflite.dart';

import '../../models/holiday/holiday.dart';
import '../db_provider.dart';

class HolidayDao {
  //Holiday
  final dbProvider = DatabaseProvider.db;

  Future<List<Holiday>> getHolidayList() async {
    var db = await dbProvider.database;
    var result = await db!.rawQuery("SELECT * FROM holiday ORDER BY id ASC");
    List<Holiday> list = result.isNotEmpty
        ? result.map((u) => Holiday.fromJson(u)).toList()
        : [];
    return list;
  }

  Future<Holiday> getSingleHoliday(int id) async {
    var db = await dbProvider.database;
    List<Map<String, Object?>> result;
    result = await db!.rawQuery("SELECT * FROM holiday WHERE holidayId = $id");

    Holiday holiday = Holiday.fromJson(result[0]);
    return holiday;
  }

  Future insertHoliday(List<Holiday> HolidayList) async {

    final db = await dbProvider.database;
    Batch batch = db!.batch();

    for (int i = 0; i < HolidayList.length; i++) {
      batch.insert("holiday", HolidayList[i].toJson());
    }
    await batch.commit(noResult: true);

    return "success";
  }

  insertSingleHoliday(Holiday holiday) async {
    final db = await dbProvider.database;
    final result = await db!.insert("holiday", holiday.toJson());
    return result;
  }

  updateHoliday(Holiday holiday) async {
    Database? db = await dbProvider.database;
    final result = await db!.update(
      'holiday',
      holiday.toJson(),
      where: "id = ?",
      whereArgs: [holiday.id],
    );
    return result;
  }

  Future<int> deleteHolidayRecords() async {
    Database? db = await dbProvider.database;
    var result = db!.rawDelete('Delete from holiday');
    return result;
  }
}
