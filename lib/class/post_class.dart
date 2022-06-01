import 'package:portfolio_post/class/user_class.dart';

import 'dateText_class.dart';

class Post {
  final String postUid;
  final String title;
  final String text;
  final int numOfLikes;
  final List<String> likedUsers;
  final Author author;
  final String createdTime;
  final String? modifiedTime;
  final String? category;

  Post({required this.likedUsers, required this.title, required this.postUid, required this.author, required this.text, required this.numOfLikes, this.modifiedTime, required this.createdTime, this.category});

  factory Post.fromJson(Map<String, dynamic> json) {
    List<String> _likedUsers = [];
    if (json["likedUsers"] != null) _likedUsers = List<String>.from(json["likedUsers"]);
    return Post(
      title: json["title"].toString(),
      text: json["text"].toString(),
      postUid: json["postUid"].toString(),
      author: Author.fromJson(json["author"] as Map<String, dynamic>),
      numOfLikes: json["numOfLikes"] ?? 0,
      likedUsers: _likedUsers,
      createdTime: DateText.convertISOToString(json["createdTime"].toString()),
      modifiedTime: DateText.convertISOToString(json["modifiedTime"] ?? ""),
      category: json["category"].toString(),
    );
  }

  factory Post.like({required Post post, required int numOfLikes, required List<String> likedUsers}) => Post(
    text: post.text,
    postUid: post.postUid,
    title: post.title,
    numOfLikes: numOfLikes,
    likedUsers: post.likedUsers,
    author: post.author,
    createdTime: post.createdTime,
    modifiedTime: post.modifiedTime,
    category: post.category,
  );
}

class PostBody {
  final String title;
  final String text;
  final Author author;
  final String? category;
  final List<String> filePaths;

  PostBody({required this.title, required this.text, required this.author, required this.category, required this.filePaths});

  Map<String, dynamic> toJson() => {
    "title": this.title,
    "text": this.text,
    "author": this.author,
    "category": this.category,
    "filePaths": this.filePaths,
  };
}