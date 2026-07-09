import 'dart:async';
import 'package:sqflite/sqflite.dart';
import '../../../models/expense/expense_product/expense_product.dart';
import '../../db_provider.dart';


class ExpenseProductDao {
   final dbProvider = DatabaseProvider.db;

  Future<List<ExpenseProduct>> getExpenseProductList() async {
    var db = await dbProvider.database;
    var result = await db!.rawQuery("SELECT * FROM expenseProduct");
    List<ExpenseProduct> list = result.isNotEmpty
        ? result.map((u) => ExpenseProduct.fromJson(u)).toList()
        : [];
    return list;
  }

  
  Future<ExpenseProduct> getSingleExpenseProduct(int id) async {
    var db = await dbProvider.database;
    var result = await db!
        .rawQuery("SELECT * FROM expenseProduct WHERE expenseProductId = $id");
    List<ExpenseProduct> list = result.isNotEmpty
        ? result.map((u) => ExpenseProduct.fromJson(u)).toList()
        : [];
    ExpenseProduct expense = list[0];
    return expense;
  }

  Future insertExpenseProduct(List<ExpenseProduct> expenseProductList) async {

    final db = await dbProvider.database;
    Batch batch = db!.batch();

    for (int i = 0; i < expenseProductList.length; i++) {
      batch.insert("expenseProduct", expenseProductList[i].toJson());
    }
    await batch.commit(noResult: true);

    return "success";
  }

  updateExpense(ExpenseProduct expense) async {
    Database? db = await dbProvider.database;
    final result = await db!.update(
      'expenseProduct',
      expense.toJson(),
      where: "id = ?",
      whereArgs: [expense.id],
    );
    return result;
  }

  deleteExpenseRecords() async {
    Database? db = await dbProvider.database;
    var result = db!.rawQuery('Delete from expenseProduct');
  }
}
