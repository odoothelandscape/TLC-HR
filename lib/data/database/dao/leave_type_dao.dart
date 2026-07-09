import 'dart:async';
import 'package:sqflite/sqflite.dart';
import '../../models/leave_type/leave_type.dart';
import '../db_provider.dart';

class LeaveTypeDao {
  //LeaveType
  final dbProvider = DatabaseProvider.db;

  Future<List<LeaveType>> getLeaveTypeList() async {
    var db = await dbProvider.database;
    var result = await db!.rawQuery("SELECT * FROM leaveType ORDER BY id DESC");
    List<LeaveType> list = result.isNotEmpty
        ? result.map((u) => LeaveType.fromJson(u)).toList()
        : [];
    return list;
  }

  Future<LeaveType> getSingleLeaveTypeById(int id) async {
    var db = await dbProvider.database;
    List<Map<String, Object?>> result;
    result = await db!.rawQuery("SELECT * FROM leaveType WHERE leaveTypeId = $id");

    LeaveType leaveType = LeaveType.fromJson(result[0]);
    return leaveType;
  }

   Future<LeaveType> getSingleLeaveTypeByCode(String code) async {
    var db = await dbProvider.database;
    List<Map<String, Object?>> result;
    result = await db!.rawQuery("SELECT * FROM leaveType WHERE leave_type = '$code'");

    LeaveType leaveType = LeaveType.fromJson(result[0]);
    return leaveType;
  }


  Future insertLeaveType(List<LeaveType> LeaveTypeList) async {

    final db = await dbProvider.database;
    Batch batch = db!.batch();

    for (int i = 0; i < LeaveTypeList.length; i++) {
      batch.insert("leaveType", LeaveTypeList[i].toJson());
    }
    await batch.commit(noResult: true);

    return "success";
  }

  insertSingleLeaveType(LeaveType LeaveType) async {
    final db = await dbProvider.database;
    final result = await db!.insert("leaveType", LeaveType.toJson());
    return result;
  }

  updateLeaveType(LeaveType LeaveType) async {
    Database? db = await dbProvider.database;
    final result = await db!.update(
      'leaveType',
      LeaveType.toJson(),
      where: "id = ?",
      whereArgs: [LeaveType.id],
    );
    return result;
  }

  Future<int> deleteLeaveTypeRecords() async {
    Database? db = await dbProvider.database;
    var result = db!.rawDelete('Delete from leaveType');
    return result;
  }
}
