import 'package:portfolio_post/class/user_class.dart' show Author;

class Comment {
  final String commentUid;
  final String text;
  final Author author;
  final bool isPrivate;
  final String createdTime;
  final String? modifiedTime;
  final List<Comment> comments;

  Comment({required this.commentUid, required this.text, required this.author, this.isPrivate = false, required this.createdTime, this.modifiedTime, required this.comments});

  factory Comment.fromJson(Map<String, dynamic> json) {
    List<Comment> _commentsList = [];
    if (json.containsKey("comments")) {
      List<Map<String, dynamic>> _subComments = List<Map<String, dynamic>>.from(json["comments"]);
      _subComments.forEach((Map<String, dynamic> js) => _commentsList.add(Comment.fromJson(js)));
    }
    String _convertISOToString(String iso) {
      if (iso.isEmpty) return "";
      final DateTime _UTC = DateTime.parse(iso);
      final String _text = "${_UTC.year}년 ${_UTC.month}월 ${_UTC.day}일";
      return _text;
    };
    return Comment(
      commentUid: json["commentUid"].toString(),
      author: Author.fromJson(json["author"] as Map<String, dynamic>),
      text: json["text"].toString(),
      isPrivate: json["isPrivate"] as bool,
      createdTime: _convertISOToString(json["createdTime"].toString()),
      modifiedTime: _convertISOToString(json["modifiedTime"] ?? ""),
      comments: _commentsList,
    );
  }
}

class CommentBody {
  final String text;
  final Author author;
  final bool isPrivate;
  final String postUid;
  final String? mainCommentUid;

  CommentBody({this.mainCommentUid, required this.text, required this.author, required this.isPrivate, required this.postUid});

  Map<String, dynamic> toJson() => {
    "text": this.text,
    "author": this.author.toJson(),
    "isPrivate": this.isPrivate,
    "postUid": this.postUid,
    if (this.mainCommentUid != null) "mainCommentUid": this.mainCommentUid,
  };
}