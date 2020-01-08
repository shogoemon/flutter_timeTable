import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TimeTableDB {
  static Database connectedDB;

  static Future<String> getPath() async {
    //パスを取得
    return join(await getDatabasesPath(), 'timeTable.db');
  }

  static Future<Database> connectDB() async {
    //データベースを返す。テーブルがなければ作成する。
    connectedDB ??= await openDatabase(
      await getPath(),
      onCreate: (Database db, int version) async {
        createTimeTable(db);
      },
      version: 1,
    );
    return connectedDB;
  }

  static void createTimeTable(Database db) async {
    //テーブルを作成
    await db.execute(
        'create table timeTable(week text,period integer,subject text,teacher text,room text)');
  }

  static Future<int> insertData(
      {String week,
      String period,
      String subject,
      String teacher,
      String room}) async {
    //returnのintが何の値なのか
    return await connectedDB.insert('timeTable', {
      'week': week,
      'period': period,
      'subject': subject,
      'teacher': teacher,
      'room': room
    });
  }

  static Future<List<Map<String, dynamic>>> getTableData() async {
    return await connectedDB.query('timeTable');
  }

  static Future<void> updateData(
      {String week,
      String period,
      String subject,
      String teacher,
      String room}) async {
    return await connectedDB.update('timeTable', {
      'week': week,
      'period': period,
      'subject': subject,
      'teacher': teacher,
      'room': room
    },
        where: 'week=? AND period=?', whereArgs: [week, period]
    );
  }

  static Future searchData(String week, String period) async {
    return await connectedDB.query('timeTable',
        where: 'week=? AND period=?', whereArgs: [week, period]);
  }
}
