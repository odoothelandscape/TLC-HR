import 'dart:async';
import 'package:sqflite/sqflite.dart';
import '../../models/payslip_line/payslip_line.dart';
import '../db_provider.dart';

class PayslipLineDao {
  //PayslipLine
  final dbProvider = DatabaseProvider.db;

  Future<List<PayslipLine>> getPayslipLineList() async {
    var db = await dbProvider.database;
    var result = await db!.rawQuery("SELECT * FROM paySlipLine ORDER BY id DESC");
    List<PayslipLine> list = result.isNotEmpty
        ? result.map((u) => PayslipLine.fromJson(u)).toList()
        : [];
    return list;
  }

    Future<List<PayslipLine>> getPayslipLineListBySlipId(int hdrSlipId) async {
    var db = await dbProvider.database;
    var result = await db!.rawQuery("SELECT * FROM paySlipLine WHERE payslip_id = $hdrSlipId ORDER BY id DESC");
    List<PayslipLine> list = result.isNotEmpty
        ? result.map((u) => PayslipLine.fromJson(u)).toList()
        : [];
    return list;
  }

  Future<PayslipLine> getSinglePayslipLineById(int id) async {
    var db = await dbProvider.database;
    List<Map<String, Object?>> result;
    result = await db!.rawQuery("SELECT * FROM paySlipLine WHERE payslipLineId = $id");

    if (result.isNotEmpty) {
      PayslipLine payslipLine = PayslipLine.fromJson(result[0]);
      return payslipLine;
    } else {
      throw Exception('PayslipLine not found with id $id');
    }
  }

  Future insertPayslipLine(List<PayslipLine> PayslipLineList) async {

    final db = await dbProvider.database;
    Batch batch = db!.batch();

    for (int i = 0; i < PayslipLineList.length; i++) {
      batch.insert("paySlipLine", PayslipLineList[i].toJson());
    }
    await batch.commit(noResult: true);

    return "success";
  }

  insertSinglePayslipLine(PayslipLine PayslipLine) async {
    final db = await dbProvider.database;
    final result = await db!.insert("paySlipLine", PayslipLine.toJson());
    return result;
  }

  updatePayslipLine(PayslipLine PayslipLine) async {
    Database? db = await dbProvider.database;
    final result = await db!.update(
      'paySlipLine',
      PayslipLine.toJson(),
      where: "id = ?",
      whereArgs: [PayslipLine.id],
    );
    return result;
  }

  Future<int> deletePayslipLineRecords() async {
    Database? db = await dbProvider.database;
    var result = db!.rawDelete('Delete from paySlipLine');
    return result;
  }
}
