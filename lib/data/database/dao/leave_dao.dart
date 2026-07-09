import 'dart:async';
import 'package:sqflite/sqflite.dart';

import '../../models/leave/leave.dart';
import '../db_provider.dart';

class LeaveDao {
  //Leave
  final dbProvider = DatabaseProvider.db;

  Future<List<Leave>> getLeaveList() async {
    var db = await dbProvider.database;
    var result = await db!.rawQuery("SELECT * FROM leave ORDER BY id ASC");
    List<Leave> list =
        result.isNotEmpty ? result.map((u) => Leave.fromJson(u)).toList() : [];
    return list;
  }

  Future<List<Leave>> getLeaveListByUserId(int userId) async {
    var db = await dbProvider.database;
    var result = await db!.rawQuery(
        "SELECT * FROM leave WHERE user_id = $userId  ORDER BY id DESC");
    List<Leave> list =
        result.isNotEmpty ? result.map((u) => Leave.fromJson(u)).toList() : [];
    // print(
    //     'result ${result.toList()} length: ${result.toList().length}} '); //To Remove log
    return list;
  }

  Future<List<Leave>> getLeaveListByUserAndEmpId(int userId, int empId) async {
    var db = await dbProvider.database;
    var result = await db!.rawQuery(
        "SELECT * FROM leave WHERE user_id = $userId AND employee_id = $empId ORDER BY id DESC");
    List<Leave> list =
        result.isNotEmpty ? result.map((u) => Leave.fromJson(u)).toList() : [];
    return list;
  }

   Future<List<Leave>> getLeaveListBySupervisor(int deptId,int uid) async {
    var db = await dbProvider.database;
    var result = await db!.rawQuery(
        "SELECT * FROM leave where department_id =$deptId and  user_id = $uid and (state = 'submit' or state='confirm') ORDER BY id DESC");
    List<Leave> list = result.isNotEmpty
        ? result.map((u) => Leave.fromJson(u)).toList()
        : [];
    return list;
  }


  Future<List<Leave>> getLeaveListByManager(int deptId,int uid) async {
    var db = await dbProvider.database;
    var result = await db!.rawQuery(
        "SELECT * FROM leave where department_id =$deptId and user_id = $uid and (state='submit' or state='confirm' or state='approve') ORDER BY id DESC");
    List<Leave> list = result.isNotEmpty
        ? result.map((u) => Leave.fromJson(u)).toList()
        : [];
    return list;
  }


  Future<List<Leave>> getLeaveListByHr(int uid) async {
    var db = await dbProvider.database;
    var result = await db!.rawQuery(
        "SELECT * FROM Leave where user_id = $uid and (state='submit' or state='confirm' or state='approve' or state='validate') ORDER BY id DESC");
    List<Leave> list = result.isNotEmpty
        ? result.map((u) => Leave.fromJson(u)).toList()
        : [];
    return list;
  }

  Future<Leave> getSingleLeave(int id) async {
    var db = await dbProvider.database;
    List<Map<String, Object?>> result;
    result = await db!.rawQuery("SELECT * FROM leave WHERE leaveId = $id");

    if (result.isEmpty) {
      throw Exception('Leave not found for id $id');
    }
    Leave leave = Leave.fromJson(result.first);
    return leave;
  }

  Future insertLeave(List<Leave> LeaveList) async {
    //print('insertLeave-----$LeaveList'); //To Remove log

    final db = await dbProvider.database;
    Batch batch = db!.batch();

    for (int i = 0; i < LeaveList.length; i++) {
      batch.insert("leave", LeaveList[i].toJson());
    }
    await batch.commit(noResult: true);

    return "success";
  }

  insertSingleLeave(Leave Leave) async {
    final db = await dbProvider.database;
    final result = await db!.insert("leave", Leave.toJson());
    return result;
  }

  updateLeave(Leave Leave) async {
    Database? db = await dbProvider.database;
    final result = await db!.update(
      'leave',
      Leave.toJson(),
      where: "id = ?",
      whereArgs: [Leave.id],
    );
    return result;
  }

  Future<int> deleteLeaveRecords() async {
    Database? db = await dbProvider.database;
    var result = await db!.rawDelete('Delete from leave');
    return result;
  }
}
