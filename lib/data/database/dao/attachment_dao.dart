import 'dart:async';
import 'package:sqflite/sqflite.dart';

import '../../models/attachment/attachment.dart';
import '../db_provider.dart';

class AttachmentDao {
  //Attachment
  final dbProvider = DatabaseProvider.db;

  Future<List<Attachment>> getAttachmentList() async {
    var db = await dbProvider.database;
    var result =
        await db!.rawQuery("SELECT * FROM attachment ORDER BY id DESC");
    List<Attachment> list = result.isNotEmpty
        ? result.map((u) => Attachment.fromJson(u)).toList()
        : [];
    return list;
  }

    Future<List<Attachment>> getAttachmentListById(int id) async {
    var db = await dbProvider.database;
    var result =
        await db!.rawQuery("SELECT * FROM attachment  WHERE attachmentId = $id ORDER BY id DESC");
    List<Attachment> list = result.isNotEmpty
        ? result.map((u) => Attachment.fromJson(u)).toList()
        : [];
    return list;
  }
  
  Future<Attachment> getSingleAttachmentById(int id) async {
    var db = await dbProvider.database;
    List<Map<String, Object?>> result;
    result = await db!.rawQuery("SELECT * FROM attachment WHERE attachmentId = $id");

    if (result.isEmpty) {
      throw StateError('No attachment found with id $id');
    }
    Attachment attachment = Attachment.fromJson(result[0]);
    return attachment;
  }

  Future insertAttachment(List<Attachment> attachmentList) async {

    final db = await dbProvider.database;
    Batch batch = db!.batch();

    for (int i = 0; i < attachmentList.length; i++) {
      batch.insert("attachment", attachmentList[i].toJson());
    }
    await batch.commit(noResult: true);

    return "success";
  }

  insertSingleAttachment(Attachment attachment) async {
    final db = await dbProvider.database;
    final result = await db!.insert("attachment", attachment.toJson());
    return result;
  }

  updateAttachment(Attachment attachment) async {
    Database? db = await dbProvider.database;
    final result = await db!.update(
      'attachment',
      attachment.toJson(),
      where: "id = ?",
      whereArgs: [attachment.id],
    );
    return result;
  }

  Future<int> deleteAttachmentRecords() async {
    Database? db = await dbProvider.database;
    var result = db!.rawDelete('Delete from attachment');
    return result;
  }
}
