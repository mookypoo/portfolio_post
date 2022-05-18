import 'package:portfolio_post/class/user_class.dart';

class Preview {
  final String postUid;
  final String title;
  final String text;
  final String userName;
  final String? category;

  Preview({required this.postUid, required this.title, required this.text, required this.userName, required this.category});

  factory Preview.fromJson(Map<String, dynamic> json) => Preview(
    category: json["category"].toString(),
    title: json["title"].toString(),
    text: json["text"].toString(),
    postUid: json["postUid"].toString(),
    userName: json["userName"].toString(),
  );

  factory Preview.edited({required String? category, required Preview preview, required String title, required String text}) => Preview(
    text: text.substring(0, text.length > 100 ? 100 : text.length),
    title: title,
    postUid: preview.postUid,
    userName: preview.userName,
    category: category,
  );
}

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
  final List<int>? filePath;
  static String convertISOToString(String iso) {
    if (iso.isEmpty) return "";
    final DateTime _UTC = DateTime.parse(iso);
    final String _text = "${_UTC.year}년 ${_UTC.month}월 ${_UTC.day}일";
    return _text;
  }

  Post({required this.likedUsers, required this.title, required this.postUid, required this.author, required this.text, required this.numOfLikes, this.modifiedTime, required this.createdTime, required this.category, this.filePath});

  factory Post.fromJson(Map<String, dynamic> json) {
    print(json["filePath"]["data"]);
    return Post(
      title: json["title"].toString(),
      text: json["text"].toString(),
      postUid: json["postUid"].toString(),
      author: Author.fromJson(json["author"] as Map<String, dynamic>),
      numOfLikes: json["numOfLikes"] ?? 0,
      likedUsers: json["likedUsers"] ?? [],
      createdTime: Post.convertISOToString(json["createdTime"].toString()),
      modifiedTime: Post.convertISOToString(json["modifiedTime"] ?? ""),
      category: json["category"].toString(),
      filePath: List<int>.from(json["filePath"]["data"]),
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

  factory Post.edit({required String? category, required Post post, required String text, required String title, required String modifiedTime}) => Post(
    text: text,
    postUid: post.postUid,
    title: title,
    numOfLikes: post.numOfLikes,
    likedUsers: post.likedUsers,
    author: post.author,
    createdTime: post.createdTime,
    modifiedTime: Post.convertISOToString(modifiedTime),
    category: category,
  );
}