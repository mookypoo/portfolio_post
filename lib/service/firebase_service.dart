import '../class/auth_class.dart';
import '../class/user_class.dart';
import '../repos/connect.dart';
import '../repos/sqflite_repo.dart';

class FirebaseService {
  Connect _connect = Connect();
  SqfliteRepo _sqfliteRepo = SqfliteRepo();

  final String _tableName = "firebase";

  FirebaseService(){
    print("firebase service init");
  }

  /// firebase signup --> success --> realtime db --> success --> set sql --> success --> return uid
  /// firebase signup --> success --> realtime db --> error --> ??
  /// firebase signup --> error --> return error msg
  Future<Object> signup({required SignUpInfo info}) async {
    final Map<String, dynamic> _body = {"displayName": info.name, "email": info.email, "password": info.pw, "returnSecureToken": true,};

    try {
      final Map<String, dynamic> _res = await this._connect.reqPostServer(path: "auth/sign/up", cb: (ReqModel rm) {}, body: _body);
      if (_res.containsKey("data")) {
        final String _userUid = _res["data"]["localId"].toString();
        final String _idToken = _res["data"]["idToken"].toString();
        final bool _success = await this._saveUserInfoDb(info: info, uid: _userUid, idToken: _idToken);
        print("save user info db: ${_success}");
        if (_success) {
          await this._setFirebaseSql(info: _res["data"]);
          return User(userName: info.name, userUid: _userUid, idToken: _idToken);
        } else {
          // todo realtime db error handling
        }
      }
      if (_res.containsKey("error")) {
        if (_res["error"]["message"].toString() == "WEAK_PASSWORD") return {"error": "더 강화된 비밀번호를 사용하세요."};
        if (_res["error"]["message"].toString() == "INVALID_EMAIL") return {"error": "잘못된 이메일 주소입니다."};
        if (_res["error"]["message"].toString() == "EMAIL_EXISTS") return {"error": "이미 가입한 이메일입니다."};
        if (_res["error"]["message"].toString() == "TOO_MANY_ATTEMPTS_TRY_LATER") return {"error": "비정상적인 활동으로 일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요."};
        return {"error": _res["error"]["message"].toString()};
      }
    } catch (e) {
      print(e);
    }
    return {};
  }

  /// send user info to realtime db
  Future<bool> _saveUserInfoDb({required SignUpInfo info, required String uid, required String idToken}) async {
    print("idToekn: ${idToken}");
    final Map<String, dynamic> _body = {"userUid": uid, "info": info.toJson(), "idToken": idToken};
    try {
      final Map<String, dynamic> _res = await this._connect.reqPostServer(path: "auth/saveUserInfo", cb: (ReqModel rm) {}, body: _body);
      if (_res.containsKey("data")) return true;
    } catch (e) {
      print(e);
    }
    return false;
  }

  // sign in 할때는 새로 id token 저장하기
  Future<Object> signIn({required String email, required String pw, String? username}) async {
    final Map<String, dynamic> _body = {"email": email, "password": pw, "returnSecureToken": true,};
    try {
      final Map<String, dynamic> _res = await this._connect.reqPostServer(path: "auth/sign/in", cb: (ReqModel rm) {}, body: _body);
      if (_res.containsKey("data")){
        await this._setFirebaseSql(info: _res["data"]);
        return User(userName: _res["data"]["displayName"].toString(), userUid: _res["data"]["localId"].toString(), idToken: _res["data"]["idToken"].toString());
      }
      if (_res.containsKey("error")){
        if (_res["error"]["message"].toString() == "INVALID_PASSWORD") return {"error": "잘못된 비밀번호입니다."};
        if (_res["error"]["message"].toString() == "EMAIL_NOT_FOUND") return {"error": "아직 가입하지 않은 이메일입니다."};
      }
    } catch (e) {
      print(e);
    }
    return {};
  }

  Future<void> signOut({required User user}) async {
    await this._sqfliteRepo.dropTable(tableName: this._tableName);
    await this._sqfliteRepo.closeDb();
    try {
      // todo unexpected end of input
      await this._connect.reqPostServer(path: "/user/deleteDeviceToken", cb: (ReqModel rm) {}, body: user.toJson());
    } catch (e) {
      print(e);
    }
  }

  Future<bool?> autoAuth({required String userUid, required String idToken}) async {
    final Map<String, String> _body = {"userUid": userUid, "idToken": idToken};
    try {
      final Map<String, dynamic> _res = await this._connect.reqPostServer(path: "/auth/autoAuth", cb: (ReqModel rm) {}, body: _body);
      if (_res.containsKey("data")) return true;
      if (_res.containsKey("error")) return false;
    } catch (e) {
      print(e);
    }
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
      final _int = await this._sqfliteRepo.createTable(createTableSql: _sql, insertSql: _insertSql, value: _value);
      print(_int);
    } else {
      final String _updateSql = "UPDATE ${this._tableName} SET username = ?, id_token = ?, email = ?, refresh_token = ?, expires = ?, user_uid = ? where id = 1";
      final _int = await this._sqfliteRepo.updateData(sql: _updateSql, value: _value);
      print(_int);
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
    /* expire만 다름????? 왜 refresh toekn이랑 id token 이 같은게 반환되지? */
    final int _changes = await this._sqfliteRepo.updateData(sql: _updateSql, value: _value);
    if (_changes == 1) return true;
    return false;
  }

  /// refresh token --> success --> updated sql --> success --> return true
  /// refresh token fail or update sql fail --> false
  /// server disconnect = false
  Future<Map<String, dynamic>> refreshToken({required String refreshToken, required String userUid}) async {
    final Map<String, String> _body = {"refreshToken": refreshToken, "userUid": userUid};
    try {
      final Map<String, dynamic> _res = await this._connect.reqPostServer(path: "auth/refreshToken", cb: (ReqModel rm) {}, body: _body);
      if (_res.containsKey("data")) {
        final bool _success = await this._updateTokenSql(info: _res["data"]);
        if (_success) return _res["data"];
      }
      if (_res.containsKey("error")){
        // todo error handling
      }
    } catch (e) {
      print(e);
    }
    return {};
  }

}