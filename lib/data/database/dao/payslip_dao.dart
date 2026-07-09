import 'dart:async';
import 'package:sqflite/sqflite.dart';

import '../../models/payslip/payslip.dart';
import '../db_provider.dart';

class PayslipDao {
  //Payslip
  final dbProvider = DatabaseProvider.db;

  Future<List<Payslip>> getPayslipList() async {
    var db = await dbProvider.database;
    var result = await db!.rawQuery("SELECT * FROM paySlip ORDER BY id DESC");
    List<Payslip> list = result.isNotEmpty
        ? result.map((u) => Payslip.fromJson(u)).toList()
        : [];
    return list;
  }

  
  Future<List<Payslip>> getAllPayslips() async {
    var db = await dbProvider.database;
    var result = await db!.rawQuery("SELECT * FROM paySlip ORDER BY id DESC");
    List<Payslip> list = result.isNotEmpty
        ? result.map((u) => Payslip.fromJson(u)).toList()
        : [];
    return list;
  }

  Future<Payslip> getSinglePayslip(int id) async {
    var db = await dbProvider.database;
    List<Map<String, Object?>> result;
    result = await db!.rawQuery("SELECT * FROM paySlip WHERE payslipId = $id");

    Payslip payslip = Payslip.fromJson(result[0]);
    return payslip;
  }

  Future insertPayslip(List<Payslip> PayslipList) async {

    final db = await dbProvider.database;
    Batch batch = db!.batch();

    for (int i = 0; i < PayslipList.length; i++) {
      batch.insert("paySlip", PayslipList[i].toJson());
    }
    await batch.commit(noResult: true);

    return "success";
  }

  insertSinglePayslip(Payslip Payslip) async {
    final db = await dbProvider.database;
    final result = await db!.insert("paySlip", Payslip.toJson());
    return result;
  }

  updatePayslip(Payslip Payslip) async {
    Database? db = await dbProvider.database;
    final result = await db!.update(
      'paySlip',
      Payslip.toJson(),
      where: "id = ?",
      whereArgs: [Payslip.id],
    );
    return result;
  }

  Future<int> deletePayslipRecords() async {
    Database? db = await dbProvider.database;
    var result = db!.rawDelete('Delete from paySlip');
    return result;
  }
}
