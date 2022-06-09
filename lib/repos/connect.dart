import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class Connect {
  final String _serverEndPoint = "https://us-central1-mooky-post.cloudfunctions.net";
  //final String _serverEndPoint = "http://192.168.35.146:3000";
  final Map<String, String> _headers = {"Mooky": "post", "content-type":"application/json"};

  Future<T?> reqPostServer<T>({required String path, void Function(ReqModel)? cb, Map<String, String>? headers, dynamic body}) async {
    String _path = path.trim();
    if (!_path.startsWith("/")) _path = "/" + _path;

    try {
      final http.Response _res = await http.post(Uri.parse(this._serverEndPoint + _path),
        headers: {...headers ?? {}, ...this._headers},
        body: json.encode(body),
      ).timeout(Duration(seconds: 13), onTimeout: () async => await http.Response("null", 404));
      if (cb != null) cb(ReqModel(statusCode: _res.statusCode));

      print(_res.body);
      if (_res.statusCode == 404) return {"error": "Sorry, we could not find the page you requested"} as T;
      if (_res.headers["content-type"] == "text/html; charset=utf-8") return _res.body as T;
      return json.decode(_res.body) as T;
    } catch (e) {
      if (e.runtimeType == SocketException) return {"error": "We could not connect to the server right now.\nPlease try again later."} as T;
      print(e);
      return {"error": e.toString()} as T;// throw e;
    }
  }

  Future<T?> reqGetServer<T>({required String path, void Function(ReqModel)? cb, Map<String, String>? headers}) async {
    String _path = path.trim();
    if (!_path.startsWith("/")) _path = "/" + _path;

    try {
      final http.Response _res = await http.get(
          Uri.parse(this._serverEndPoint + _path),
          headers: {...headers ?? {}, ...this._headers}).timeout(Duration(seconds: 13), onTimeout: () async => http.Response("null", 404));
      if (cb != null) cb(ReqModel(statusCode: _res.statusCode));
      print(_res.body);

      if (_res.statusCode == 404) return {"error": "Sorry, could not find the page you requested"} as T;
      if (_res.headers["content-type"] == "text/html; charset=utf-8") return _res.body as T;
      return json.decode(_res.body) as T;
    } catch (e) {
      if (e.runtimeType == SocketException) return {"error": "We could not connect to the server right now.\nPlease try again later."} as T;
      print(e); // throw e;
      return {"error": e.toString()} as T;
    }
  }
}

class ReqModel {
  int statusCode;
  ReqModel({required this.statusCode});
}

