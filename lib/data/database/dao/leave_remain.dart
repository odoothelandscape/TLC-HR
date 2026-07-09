import 'dart:async';
import 'package:sqflite/sqflite.dart';
import '../../models/leave_remain/leave_remain.dart';
import '../db_provider.dart';

class LeaveRemainDao {
  //LeaveRemain
  final dbProvider = DatabaseProvider.db;

  Future<List<LeaveRemain>> getLeaveRemainList() async {
    var db = await dbProvider.database;
    var result =
        await db!.rawQuery("SELECT * FROM leaveRemain ORDER BY id DESC");
    List<LeaveRemain> list = result.isNotEmpty
        ? result.map((u) => LeaveRemain.fromJson(u)).toList()
        : [];
    return list;
  }

  Future<LeaveRemain> getSingleLeaveRemainById(int id) async {
    var db = await dbProvider.database;
    List<Map<String, Object?>> result;
    result = await db!
        .rawQuery("SELECT * FROM leaveRemain WHERE leaveRemainId = $id");

    LeaveRemain leaveRemain = LeaveRemain.fromJson(result[0]);
    return leaveRemain;
  }

  Future<LeaveRemain> getSingleLeaveRemainByLeaveTypeId(int leaveTypeId) async {
    var db = await dbProvider.database;
    List<Map<String, Object?>> result;
    result = await db!.rawQuery(
        "SELECT * FROM leaveRemain WHERE leaveRemainId = $leaveTypeId");

    LeaveRemain leaveRemain = LeaveRemain.fromJson(result[0]);
    return leaveRemain;
  }

  Future<LeaveRemain> getSingleLeaveRemainByCode(String code) async {
    var db = await dbProvider.database;
    List<Map<String, Object?>> result;
    result =
        await db!.rawQuery("SELECT * FROM leaveRemain WHERE code = '$code'");

    LeaveRemain leaveRemain = LeaveRemain.fromJson(result[0]);
    return leaveRemain;
  }

  Future insertLeaveRemain(List<LeaveRemain> LeaveRemainList) async {

    final db = await dbProvider.database;
    Batch batch = db!.batch();

    for (int i = 0; i < LeaveRemainList.length; i++) {
      batch.insert("leaveRemain", LeaveRemainList[i].toJson());
    }
    await batch.commit(noResult: true);

    return "success";
  }

  insertSingleLeaveRemain(LeaveRemain LeaveRemain) async {
    final db = await dbProvider.database;
    final result = await db!.insert("leaveRemain", LeaveRemain.toJson());
    return result;
  }

  updateLeaveRemain(LeaveRemain LeaveRemain) async {
    Database? db = await dbProvider.database;
    final result = await db!.update(
      'leaveRemain',
      LeaveRemain.toJson(),
      where: "id = ?",
      whereArgs: [LeaveRemain.id],
    );
    return result;
  }

  Future<int> deleteLeaveRemainRecords() async {
    Database? db = await dbProvider.database;
    var result = db!.rawDelete('Delete from leaveRemain');
    return result;
  }
}
