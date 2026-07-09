import 'dart:async';
import 'package:sqflite/sqflite.dart';

import '../../models/leave_reason/leave_reason.dart';
import '../db_provider.dart';

class LeaveReasonDao {
  //LeaveReason
  final dbProvider = DatabaseProvider.db;

  Future<List<LeaveReason>> getLeaveReasonList() async {
    var db = await dbProvider.database;
    var result = await db!.rawQuery("SELECT * FROM leaveReason ORDER BY id DESC");
    List<LeaveReason> list = result.isNotEmpty
        ? result.map((u) => LeaveReason.fromJson(u)).toList()
        : [];
    return list;
  }

  Future<LeaveReason> getSingleLeaveReasonById(int id) async {
    var db = await dbProvider.database;
    List<Map<String, Object?>> result;
    result = await db!.rawQuery("SELECT * FROM leaveReason WHERE leaveReasonId = $id");

    if (result.isEmpty) {
      throw Exception('LeaveReason not found for id $id');
    }
    LeaveReason leaveReason = LeaveReason.fromJson(result[0]);
    return leaveReason;
  }

  Future insertLeaveReason(List<LeaveReason> LeaveReasonList) async {

    final db = await dbProvider.database;
    Batch batch = db!.batch();

    for (int i = 0; i < LeaveReasonList.length; i++) {
      batch.insert("leaveReason", LeaveReasonList[i].toJson());
    }
    await batch.commit(noResult: true);

    return "success";
  }

  insertSingleLeaveReason(LeaveReason LeaveReason) async {
    final db = await dbProvider.database;
    final result = await db!.insert("leaveReason", LeaveReason.toJson());
    return result;
  }

  updateLeaveReason(LeaveReason LeaveReason) async {
    Database? db = await dbProvider.database;
    final result = await db!.update(
      'leaveReason',
      LeaveReason.toJson(),
      where: "id = ?",
      whereArgs: [LeaveReason.id],
    );
    return result;
  }

  Future<int> deleteLeaveReasonRecords() async {
    Database? db = await dbProvider.database;
    var result = db!.rawDelete('Delete from leaveReason');
    return result;
  }
}
