import 'dart:convert';

import 'package:http/http.dart' as http;

class Connect {
  //final String _serverEndPoint = "https://us-central1-mooky-post.cloudfunctions.net";
  final String _serverEndPoint = "http://192.168.200.181:3000";
  final Map<String, String> _headers = {"Mooky": "post", "content-type":"application/json"};

  Future<T?> reqPostServer<T>({required String path, required void Function(ReqModel) cb, Map<String, String>? headers, dynamic body}) async {
    String _path = path.trim();
    if (!_path.startsWith("/")) _path = "/" + _path;

    try {
      final http.Response _res = await http.post(Uri.parse(this._serverEndPoint + _path),
        headers: {...headers ?? {}, ...this._headers},
        body: json.encode(body),
      ).timeout(Duration(seconds: 13), onTimeout: () async => await http.Response("null", 404));
      cb(ReqModel(statusCode: _res.statusCode));

      print(_res.body);
      if (_res.headers["content-type"] == "text/html; charset=utf-8") return _res.body as T;
      return json.decode(_res.body) as T;
    } catch (e) {
      print(e.toString());
      return {"error": "cannot connect to server"} as T;
    }
  }

  Future<T> reqGetServer<T>({required String path, required void Function(ReqModel) cb, Map<String, String>? headers}) async {
    String _path = path.trim();
    if (!_path.startsWith("/")) _path = "/" + _path;

    try {
      final http.Response _res = await http.get(
          Uri.parse(this._serverEndPoint + _path),
          headers: {...headers ?? {}, ...this._headers}).timeout(Duration(seconds: 13), onTimeout: () async => http.Response("null", 404));
      cb(ReqModel(statusCode: _res.statusCode));

      print(_res.body);
      print("connect-req get");
      if (_res.headers["content-type"] == "text/html; charset=utf-8") return _res.body as T;
      return json.decode(_res.body) as T;
    } catch (e) {
      print(e.toString());
      return {"error": "cannot connect to server"} as T;
    }
  }
}

class ReqModel {
  int statusCode;
  ReqModel({required this.statusCode});
}