import 'dart:async';
import 'package:sqflite/sqflite.dart';
import '../../../models/expense/expense_tax/expense_tax.dart';
import '../../db_provider.dart';


class ExpenseTaxDao {
   final dbProvider = DatabaseProvider.db;

  Future<List<ExpenseTax>> getExpenseTaxList() async {
    var db = await dbProvider.database;
    var result = await db!.rawQuery("SELECT * FROM expense_tax");
    List<ExpenseTax> list = result.isNotEmpty
        ? result.map((u) => ExpenseTax.fromJson(u)).toList()
        : [];
    return list;
  }

  
  Future<ExpenseTax> getSingleExpenseTax(int id) async {
    var db = await dbProvider.database;
    var result = await db!
        .rawQuery("SELECT * FROM expense_tax WHERE expenseTaxId = $id");
    List<ExpenseTax> list = result.isNotEmpty
        ? result.map((u) => ExpenseTax.fromJson(u)).toList()
        : [];
    ExpenseTax expense = list[0];
    return expense;
  }

  Future insertExpenseTax(List<ExpenseTax> ExpenseTaxList) async {

    final db = await dbProvider.database;
    Batch batch = db!.batch();

    for (int i = 0; i < ExpenseTaxList.length; i++) {
      batch.insert("expense_tax", ExpenseTaxList[i].toJson());
    }
    await batch.commit(noResult: true);

    return "success";
  }

  updateExpense(ExpenseTax expense) async {
    Database? db = await dbProvider.database;
    final result = await db!.update(
      'expense_tax',
      expense.toJson(),
      where: "id = ?",
      whereArgs: [expense.id],
    );
    return result;
  }

  deleteExpenseRecords() async {
    Database? db = await dbProvider.database;
    var result = db!.rawQuery('Delete from expense_tax');
  }
}
