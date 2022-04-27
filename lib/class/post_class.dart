import 'package:portfolio_post/class/user_class.dart';

class Preview {
  final String postUid;
  final String title;
  final String text;
  final String userName;

  Preview({required this.postUid, required this.title, required this.text, required this.userName});

  factory Preview.fromJson(Map<String, dynamic> json) => Preview(
    title: json["title"].toString(),
    text: json["text"].toString(),
    postUid: json["postUid"].toString(),
    userName: json["userName"].toString(),
  );

  factory Preview.edited({required Preview preview, required String title, required String text}) => Preview(
    text: text.substring(0, text.length > 100 ? 100 : text.length),
    title: title,
    postUid: preview.postUid,
    userName: preview.userName,
  );
}

class Post {
  final String postUid;
  final String title;
  //final List<Comment> comments;
  final String text;
  final int numOfLikes;
  final List<String> likedUsers;
  final Author author;
  final String createdTime;
  final String? modifiedTime;

  Post({required this.likedUsers, required this.title, required this.postUid, required this.author, required this.text, required this.numOfLikes, required this.createdTime, this.modifiedTime});

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    title: json["title"].toString(),
    text: json["text"].toString(),
    postUid: json["postUid"].toString(),
    author: Author.fromJson(json["author"] as Map<String, dynamic>),
    numOfLikes: json["numOfLikes"] ?? 0,
    likedUsers: json["likedUsers"] ?? [],
    createdTime: json["createdTime"].toString(),
    modifiedTime: json["modifiedTime"] ?? "",
  );

  factory Post.like({required Post post, required int numOfLikes, required List<String> likedUsers}) => Post(
    text: post.text,
    postUid: post.postUid,
    title: post.title,
    numOfLikes: numOfLikes,
    likedUsers: likedUsers,
    author: post.author,
    createdTime: post.createdTime,
    modifiedTime: post.modifiedTime,
  );

  factory Post.edit({required Post post, required String text, required String title, required String modifiedTime}) => Post(
    text: text,
    postUid: post.postUid,
    title: title,
    numOfLikes: post.numOfLikes,
    likedUsers: post.likedUsers,
    author: post.author,
    createdTime: post.createdTime,
    modifiedTime: modifiedTime,
  );
}