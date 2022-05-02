import '../class/user_class.dart';
import '../repos/connect.dart';

class UserService {
  Connect _connect = Connect();
  
  Future<Map<String, dynamic>> getUserInfo({required User user}) async {
    try {
      final Map<String, dynamic> _res = await this._connect.reqGetServer(path: "/user/getInfo/${user.userUid}", cb: (ReqModel rm) {});
      return _res;
    } catch (e) {
      print(e);
    }
    return {};
  }
}