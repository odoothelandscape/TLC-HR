import 'dart:async';

import 'package:sqflite/sqflite.dart';

import '../../../models/expense/expense/expense.dart';
import '../../db_provider.dart';

class ExpenseDao {
  final dbProvider = DatabaseProvider.db;

  Future<List<Expense>> getExpenseList() async {
    var db = await dbProvider.database;
    var result = await db!.rawQuery("SELECT * FROM expense ORDER BY id ASC");
    List<Expense> list = result.isNotEmpty
        ? result.map((u) => Expense.fromJson(u)).toList()
        : [];
    return list;
  }

  Future<List<Expense>> getExpenseListByAsc() async {
    var db = await dbProvider.database;
    var result = await db!.rawQuery("SELECT * FROM expense ORDER BY id ASC");
    List<Expense> list = result.isNotEmpty
        ? result.map((u) => Expense.fromJson(u)).toList()
        : [];
    return list;
  }

  Future<List<Expense>> getMobileExpenseList() async {
    var db = await dbProvider.database;
    var result = await db!.rawQuery("SELECT * FROM expense WHERE isSync = 0");
    List<Expense> list = result.isNotEmpty
        ? result.map((u) => Expense.fromJson(u)).toList()
        : [];
    return list;
  }

  Future<Expense> getSingleExpense(int id) async {
    var db = await dbProvider.database;
    var result =
        await db!.rawQuery("SELECT * FROM expense WHERE expenseId = $id");
    List<Expense> list = result.isNotEmpty
        ? result.map((u) => Expense.fromJson(u)).toList()
        : [];
    Expense expense = list[0];
    return expense;
  }

  Future insertExpense(List<Expense> expenseList) async {

    final db = await dbProvider.database;
    Batch batch = db!.batch();

    for (int i = 0; i < expenseList.length; i++) {
      batch.insert("expense", expenseList[i].toJson());
    }
    await batch.commit(noResult: true);

    return "success";
  }

  Future<int> insertSingleExpense(Expense expense) async {
    final db = await dbProvider.database;
    final result = await db!.insert("expense", expense.toJson());
    return result;
  }

  updateExpense(Expense expense) async {
    Database? db = await dbProvider.database;
    final result = await db!.update(
      'expense',
      expense.toJson(),
      where: "id = ?",
      whereArgs: [expense.id],
    );
    return result;
  }

  Future<int> deleteExpenseRecords() async {
    Database? db = await dbProvider.database;
    var result = db!.rawDelete('Delete from expense');
    return result;
  }

  Future<int> deleteExpenseRecordsById(int id) async {
    Database? db = await dbProvider.database;
    var result = db!.rawDelete('Delete from expense WHERE id = $id');
    return result;
  }

  Future<int> deleteSingleExpenseRecords(int id) async {
    Database? db = await dbProvider.database;
    var result = db!.rawDelete('Delete from expense WHERE id = $id');
    return result;
  }
}
