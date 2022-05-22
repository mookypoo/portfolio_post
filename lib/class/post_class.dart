import 'package:portfolio_post/class/photo_class.dart';
import 'package:portfolio_post/class/user_class.dart';

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

  static String convertISOToString(String iso) {
    if (iso.isEmpty) return "";
    final DateTime _UTC = DateTime.parse(iso);
    final String _text = "${_UTC.year}년 ${_UTC.month}월 ${_UTC.day}일";
    return _text;
  }

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
      createdTime: Post.convertISOToString(json["createdTime"].toString()),
      modifiedTime: Post.convertISOToString(json["modifiedTime"] ?? ""),
      category: json["category"].toString(),
    );
  }

  factory Post.init({required String createdTime, required String title, required Author author, required String text, required String postUid, String? category}) => Post(
    title: title, author: author, text: text, postUid: postUid, createdTime: Post.convertISOToString(createdTime), likedUsers: [], numOfLikes: 0,
  );

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

  factory Post.edit({required String? category, required Post post, required String text, required String title, required String modifiedTime, List<Photo>? images}) => Post(
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