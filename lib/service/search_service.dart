import 'package:flutter/widgets.dart';

import '../class/post_class.dart' show Preview;
import '../repos/connect.dart';

class SearchService {
  Connect _connect = Connect();

  Future<Map<String, dynamic>> search({required String searchText}) async {
    try {
      final Map<String, dynamic> _res = await this._connect.reqGetServer(path: "/search/${searchText}", cb: (ReqModel rm) {});
      if (_res.containsKey("data")){
        List<Preview> _previewList = [];
        if ((_res["data"] as List).isEmpty) return {"previews": _previewList};
        List<Map<String, dynamic>> _previews = List<Map<String, dynamic>>.from(_res["data"]);
        _previews.forEach((Map<String, dynamic> json) => _previewList.add(Preview.fromJson(json)));
        return {"previews": _previewList};
      }
      return _res;
    } catch (e) {
      print(e);
    }
    return {"error": ""};
  }

  static TextSpan highlightedTextSpan({required String text, required bool needHighlight}){
    return TextSpan(
      text: text,
      style: TextStyle(
        color: Color.fromRGBO(0, 0, 0, 1.0),
        backgroundColor: needHighlight ? Color.fromRGBO(255, 255, 0, 0.9) : null,
      ),
    );
  }

  static List<TextSpan> highlightedText({required String searchText, required String text}) {
    text = text.replaceAll("\n", "...");
    List<TextSpan> _text = [];
    RegExp regEx = RegExp(searchText, caseSensitive: false, multiLine: true);
    Iterable<Match> _matches = regEx.allMatches(text);
    if (_matches.length == 0) {
      return _text..add(SearchService.highlightedTextSpan(text: text, needHighlight: false));
    }
    int _startIndex = 0;
    for (int i = 0; i < _matches.length; i++) {
      final Match _match = _matches.elementAt(i);
      _text.add(SearchService.highlightedTextSpan(
        text: text.substring(_startIndex, _match.start),
        needHighlight: false,
      ));

      _text.add(SearchService.highlightedTextSpan(
        text: text.substring(_match.start, _match.end),
        needHighlight: true,
      ));

      if (i == _matches.length - 1 && _match.end != text.length) {
        _text.add(SearchService.highlightedTextSpan(
          text: text.substring(_match.end),
          needHighlight: false,
        ));
      }
      _startIndex = _match.end;
    }
    return _text;
  }
}