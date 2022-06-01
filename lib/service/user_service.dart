import '../class/user_class.dart';
import '../repos/connect.dart';

class UserService {
  Connect _connect = Connect();
  
  Future<Map<String, dynamic>> getUserInfo({required User user}) async {
    final Map<String, dynamic> _res = await this._connect.reqGetServer(path: "/user/getInfo/${user.userUid}");
    return _res;
  }
}