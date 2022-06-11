import 'package:portfolio_post/class/user_class.dart' show Author;

import 'dateText_class.dart';

class Comment {
  final String commentUid;
  final String text;
  final Author author;
  final bool isPrivate;
  final String createdTime;
  final List<Comment> comments;

  Comment({required this.commentUid, required this.text, required this.author, this.isPrivate = false, required this.createdTime, required this.comments});

  factory Comment.fromJson(Map<String, dynamic> json) {
    List<Comment> _commentsList = [];
    if (json.containsKey("comments")) {
      List<Map<String, dynamic>> _subComments = List<Map<String, dynamic>>.from(json["comments"]);
      _subComments.forEach((Map<String, dynamic> js) => _commentsList.add(Comment.fromJson(js)));
    }
    return Comment(
      commentUid: json["commentUid"].toString(),
      author: Author.fromJson(json["author"] as Map<String, dynamic>),
      text: json["text"].toString(),
      isPrivate: json["isPrivate"] as bool,
      createdTime: DateText.convertISOToString(json["createdTime"]),
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