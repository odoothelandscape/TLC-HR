import 'dart:async';
import 'package:sqflite/sqflite.dart';
import '../../../models/expense/analytic_account/analytic_account.dart';
import '../../db_provider.dart';

class AnalyticAccountDao {
  final dbProvider = DatabaseProvider.db;

  Future<List<AnalyticAccount>> getAnalyticAccountList() async {
    var db = await dbProvider.database;
    var result = await db!.rawQuery("SELECT * FROM analyticAccount");
    List<AnalyticAccount> list = result.isNotEmpty
        ? result.map((u) => AnalyticAccount.fromJson(u)).toList()
        : [];
    return list;
  }

  Future<AnalyticAccount> getSingleAnalyticAccount(int id) async {
    var db = await dbProvider.database;
    var result = await db!.rawQuery(
        "SELECT * FROM analyticAccount WHERE analyticAccountId = $id");
    List<AnalyticAccount> list = result.isNotEmpty
        ? result.map((u) => AnalyticAccount.fromJson(u)).toList()
        : [];
    AnalyticAccount analyticAccount = list[0];
    return analyticAccount;
  }

  Future insertAnalyticAccount(
      List<AnalyticAccount> AnalyticAccountList) async {

    final db = await dbProvider.database;
    Batch batch = db!.batch();

    for (int i = 0; i < AnalyticAccountList.length; i++) {
      batch.insert("analyticAccount", AnalyticAccountList[i].toJson());
    }
    await batch.commit(noResult: true);

    return "success";
  }

  updateAnalyticAccount(AnalyticAccount analyticAccount) async {
    Database? db = await dbProvider.database;
    final result = await db!.update(
      'analyticAccount',
      analyticAccount.toJson(),
      where: "id = ?",
      whereArgs: [analyticAccount.id],
    );
    return result;
  }

  deleteAnalyticAccountRecords() async {
    Database? db = await dbProvider.database;
    var result = db!.rawQuery('Delete from analyticAccount');
  }
}
