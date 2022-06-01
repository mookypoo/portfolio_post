import '../class/auth_class.dart';
import '../class/user_class.dart';
import '../repos/connect.dart';
import '../repos/sqflite_repo.dart';

class FirebaseService {
  final Connect _connect = Connect();
  final SqfliteRepo _sqfliteRepo = SqfliteRepo();
  final String _tableName = "firebase";

  Future<Map<String, dynamic>> signup({required SignUpInfo info}) async {
    final Map<String, dynamic> _body = {"displayName": info.name, "email": info.email, "password": info.pw, "returnSecureToken": true,};

    final Map<String, dynamic> _res = await this._connect.reqPostServer(path: "auth/sign/up", cb: (ReqModel rm) {}, body: _body);
    if (_res.containsKey("data")) {
      final String _userUid = _res["data"]["localId"].toString();
      final String _idToken = _res["data"]["idToken"].toString();
      final bool _success = await this._saveUserInfoDb(info: info, uid: _userUid, idToken: _idToken);
      if (_success) {
        await this._setFirebaseSql(info: _res["data"]);
        return {"user": User(userName: info.name, userUid: _userUid, idToken: _idToken)};
      }
    }
    if (_res.containsKey("error")) {
      if (_res["error"]["message"].toString() == "WEAK_PASSWORD") return {"errorText": "더 강화된 비밀번호를 사용하세요."};
      if (_res["error"]["message"].toString() == "INVALID_EMAIL") return {"errorText": "잘못된 이메일 주소입니다."};
      if (_res["error"]["message"].toString() == "EMAIL_EXISTS") return {"errorText": "이미 가입한 이메일입니다."};
      if (_res["error"]["message"].toString() == "TOO_MANY_ATTEMPTS_TRY_LATER") return {"errorText": "비정상적인 활동으로 일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요."};
      return {"errorText": _res["error"]["message"].toString()};
    }
    return _res;
  }

  /// send user info to realtime db
  Future<bool> _saveUserInfoDb({required SignUpInfo info, required String uid, required String idToken}) async {
    final Map<String, dynamic> _body = {"userUid": uid, "info": info.toJson()..addAll({"idToken": idToken})};
    final Map<String, dynamic> _res = await this._connect.reqPostServer(path: "auth/saveUserInfo", cb: (ReqModel rm) {}, body: _body);
    if (_res.containsKey("data")) return true;
    return false;
  }

  Future<Map<String, dynamic>> signIn({required String email, required String pw, String? username}) async {
    final Map<String, dynamic> _body = {"email": email, "password": pw, "returnSecureToken": true,};
    final Map<String, dynamic> _res = await this._connect.reqPostServer(path: "auth/sign/in", cb: (ReqModel rm) {}, body: _body);
    if (_res.containsKey("data")){
      await this._setFirebaseSql(info: _res["data"]);
      return {"user": User(userName: _res["data"]["displayName"].toString(), userUid: _res["data"]["localId"].toString(), idToken: _res["data"]["idToken"].toString())};
    }
    if (_res.containsKey("error")){
      if (_res["error"]["message"].toString() == "INVALID_PASSWORD") return {"errorText": "잘못된 비밀번호입니다."};
      if (_res["error"]["message"].toString() == "EMAIL_NOT_FOUND") return {"errorText": "아직 가입하지 않은 이메일입니다."};
      return {"errorText": _res["error"]["message"].toString()};
    }
    return _res;
  }

  Future<void> signOut({required User user}) async {
    await this._sqfliteRepo.dropTable(tableName: this._tableName);
    await this._sqfliteRepo.closeDb();
    await this._connect.reqPostServer(path: "/user/deleteDeviceToken", cb: (ReqModel rm) {}, body: user.toJson());
  }

  Future<bool?> autoAuth({required String userUid, required String idToken}) async {
    final Map<String, String> _body = {"userUid": userUid, "idToken": idToken};
    final Map<String, dynamic> _res = await this._connect.reqPostServer(path: "/auth/autoAuth", cb: (ReqModel rm) {}, body: _body);
    if (_res.containsKey("data")) return true;
    if (_res.containsKey("error")) return false;
    return null;
  }

  Future<bool> _tableExists() async => await this._sqfliteRepo.tableExists(tableName: this._tableName);

  Future<void> _setFirebaseSql({required Map<String, dynamic> info}) async {
    final List<String> _value = [
      info["displayName"].toString(),
      info["idToken"].toString(),
      info["email"].toString(),
      info["refreshToken"].toString(),
      DateTime.now().add(Duration(seconds: int.parse(info["expiresIn"].toString()))).toIso8601String(),
      info["localId"].toString(),
    ];

    if (!await this._tableExists()){
      final String _insertSql = "INSERT into ${this._tableName} (username, id_token, email, refresh_token, expires, user_uid) values (?, ?, ?, ?, ?, ?)";
      final String _sql = "CREATE TABLE ${this._tableName} (id INTEGER PRIMARY KEY, username TEXT, id_token TEXT, email TEXT, refresh_token TEXT, expires TEXT, user_uid TEXT)";
      await this._sqfliteRepo.createTable(createTableSql: _sql, insertSql: _insertSql, value: _value);
    } else {
      final String _updateSql = "UPDATE ${this._tableName} SET username = ?, id_token = ?, email = ?, refresh_token = ?, expires = ?, user_uid = ? where id = 1";
      await this._sqfliteRepo.updateData(sql: _updateSql, value: _value);
    }
  }

  Future<Map<String, dynamic>?> getFirebaseSql() async {
    if (await this._tableExists()) {
      final List<Map<String, dynamic>> _info = await this._sqfliteRepo.readDb(sql: "SELECT * FROM ${this._tableName}");
      return _info[0];
    }
    return null;
  }

  Future<bool> _updateTokenSql({required Map<String, dynamic> info}) async {
    final String _updateSql = "UPDATE ${this._tableName} SET id_token = ?, refresh_token = ?, expires = ? where id = 1";

    final List<String> _value = [
      info["id_token"].toString(),
      info["refresh_token"].toString(),
      DateTime.now().add(Duration(seconds: int.parse(info["expires_in"].toString()))).toIso8601String(),
    ];
    final int _changes = await this._sqfliteRepo.updateData(sql: _updateSql, value: _value);
    if (_changes == 1) return true;
    return false;
  }

  // todo redo
  Future<Map<String, dynamic>> refreshToken({required String refreshToken, required String userUid}) async {
    final Map<String, String> _body = {"refreshToken": refreshToken, "userUid": userUid};
    final Map<String, dynamic> _res = await this._connect.reqPostServer(path: "auth/refreshToken", cb: (ReqModel rm) {}, body: _body);
    if (_res.containsKey("data")) {
      final bool _success = await this._updateTokenSql(info: _res["data"]);
      if (_success) return _res["data"];
    }
    return _res;
  }

}