import 'package:sqflite/sqflite.dart';

class SqfliteRepo {

  SqfliteRepo(){
    print("sqflite repo init");
    Future(this._openDb);
  }

  Database? _db;

  Future<String> _getPath() async {
    String _path = await getDatabasesPath();
    return _path += "user";
  }

  Future<Database> _openDb() async {
    final String _path = await this._getPath();
    return await openDatabase(_path);
  }

  Future<Database> _getDb() async {
    if (this._db == null) return await this._openDb();
    return this._db!;
  }

  Future<int> createTable({required String createTableSql, required String insertSql, required List<String> value}) async {
    final Database _db = await this._getDb();
    final int _id = await _db.transaction((Transaction txn) async {
      await txn.execute(createTableSql);
      return await txn.rawInsert(insertSql, value);
    });
    return _id;
  }

  Future<bool> tableExists({required String tableName}) async {
    final Database _db = await this._getDb();
    List<Map<String, dynamic>> _list = await _db.query("sqlite_master", where: "name = ?" , whereArgs: [tableName]);
    if (_list.isEmpty) return false;
    return true;
  }

  Future<int> insertData({required String sql, required List<String> value}) async {
    final Database _db = await this._getDb();
    final int _id = await _db.transaction((Transaction txn) async => await txn.rawInsert(sql, value));
    return _id;
  }

  Future<List<Map<String, dynamic>>> readDb({required String sql}) async {
    final Database _db = await this._getDb();
    final List<Map<String, dynamic>> _data = await _db.rawQuery(sql);
    return _data;
  }

  // todo how many changes are actually made?
  Future<int> updateData({required String sql, required List<String> value}) async {
    final Database _db = await this._getDb();
    final int _changes = await _db.rawUpdate(sql, value);
    return _changes;
  }

  Future<void> deleteDb({required String tableName}) async {
    final String _path = await this._getPath();
    await deleteDatabase(_path);
  }

  Future<void> dropTable({required String tableName}) async {
    final Database _db = await this._getDb();
    if (await this.tableExists(tableName: tableName)) await _db.execute("DROP TABLE $tableName");
  }

  Future<void> closeDb() async {
    final Database _db = await this._getDb();
    await _db.close();
  }

}