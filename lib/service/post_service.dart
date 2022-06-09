import '../class/checkbox_class.dart';
import '../class/comment_class.dart';
import '../class/post_class.dart';
import '../class/preview_class.dart';
import '../class/user_class.dart';
import '../repos/connect.dart';

class PostService {
  Connect _connect = Connect();

  static final List<CheckboxClass> categories = [
    CheckboxClass(text: "Firebase"),
    CheckboxClass(text: "Flutter"),
    CheckboxClass(text: "JavaScript"),
    CheckboxClass(text: "Node.js"),
    CheckboxClass(text: "Miscellaneous"),
  ];

  Future<Map<String, dynamic>> getPreviews() async {
    final Map<String, dynamic> _res = await this._connect.reqGetServer(path: "/posts/getPreviews", cb: (ReqModel rm) {});
    if (_res.containsKey("previews")) {
      List<Preview> _previewList = [];
      if ((_res["previews"] as List<dynamic>).isNotEmpty){
        List<Map<String, dynamic>>? _previews = List<Map<String, dynamic>>.from(_res["previews"]);
        _previews.forEach((Map<String, dynamic> json) => _previewList.add(Preview.fromJson(json)));
      }
      return {"previews": _previewList};
    }
    return _res;
  }

  Future<Map<String, dynamic>> addPost({required PostBody body}) async {
    final Map<String, dynamic> _res = await this._connect.reqPostServer(path: "/posts/add", cb: (ReqModel rm) {}, body: {"post": body.toJson()});
    if (_res.containsKey("postUid") && _res.containsKey("createdTime")) return {
      "postUid": _res["postUid"],
      "preview": Preview(userName: body.author.userName, title: body.title, text: body.text, postUid: _res["postUid"], category: body.category),
    };
    return _res;
  }

  Future<Map<String, dynamic>> getPost({required String postUid}) async {
    final Map<String, dynamic> _res = await this._connect.reqGetServer(path: "/posts/getPost/${postUid}");
    if (_res.containsKey("post")) return {"post": Post.fromJson(_res["post"] as Map<String, dynamic>)};
    return _res;
  }

  Future<Map<String, dynamic>> getComments({required String postUid}) async {
    final Map<String, dynamic> _res = await this._connect.reqGetServer(path: "/comments/get/${postUid}", cb: (ReqModel rm) {});
    if (_res.containsKey("comments")) {
      List<Comment> _commentsList = [];
      if (_res["comments"] == null) return {"comments": _commentsList};
      List<Map<String, dynamic>> _comments = List<Map<String, dynamic>>.from(_res["comments"]);
      _comments.forEach((Map<String, dynamic> json) => _commentsList.add(Comment.fromJson(json)));
      return {"comments": _commentsList};
    }
    return _res;
  }

  Future<Map<String, dynamic>> like({required Post post, required String userUid}) async {
    final int _index = post.likedUsers.indexWhere((String uid) => userUid == uid);
    int _numOfLikes = post.numOfLikes;
    List<String> _likedUsers = post.likedUsers;
    final Map<String, dynamic> _body = {"postUid": post.postUid, "numOfLikes": _numOfLikes, "userUid": userUid};
    Map<String, dynamic> _res;

    if (_index == -1) {
      _numOfLikes += 1;
      _likedUsers.add(userUid);
      _res = await this._connect.reqPostServer(path: "/posts/like", cb: (ReqModel rm) {}, body: _body);
    } else {
      _numOfLikes -= 1;
      _likedUsers.remove(userUid);
      _res = await this._connect.reqPostServer(path: "/posts/unlike", cb: (ReqModel rm) {}, body: _body);
    }
    if (_res.containsKey("data")) return { "post": Post.like(post: post, numOfLikes: _numOfLikes, likedUsers: _likedUsers)};
    return _res;
  }

  Future<Map<String, dynamic>> addComment({required CommentBody body, bool commentOnComment = false}) async {
    String _param = "comment";
    if (commentOnComment) _param = "commentOnComment";

    final Map<String, dynamic> _res = await this._connect.reqPostServer(path: "/comments/add/${_param}", cb: (ReqModel rm) {}, body: body.toJson());
    if (_res.containsKey("commentUid") && _res.containsKey("createdTime")) {
      return {"comment": Comment(
        comments: [],
        createdTime: _res["createdTime"].toString(),
        commentUid: _res["commentUid"].toString(),
        author: body.author,
        text: body.text,
        isPrivate: body.isPrivate,
      )};
    };
    return _res;
  }

  Future<Map<String, dynamic>> deletePost({required String postUid, required User user}) async {
    final Map<String, dynamic> _body = {"postUid": postUid, "userUid": user.userUid, "idToken": user.idToken};
    final Map<String, dynamic> _res = await this._connect.reqPostServer(path: "/posts/delete", cb: (ReqModel rm) {}, body: _body);
    return _res;
  }

  Future<Map<String, dynamic>> editPost({required Map<String, dynamic> body}) async {
    final Map<String, dynamic> _res = await this._connect.reqPostServer(path: "/posts/edit", cb: (ReqModel rm) {}, body: body);
    return _res;
  }

  Future<Map<String, dynamic>> categoryPreviews({required List<String> categories}) async {
    String query = "";
    categories.forEach((String s) => query += "category[]=$s&");
    query = query.substring(0, query.length - 1);

    final Map<String, dynamic> _res = await this._connect.reqGetServer(path: "/posts/category?$query", cb: (ReqModel rm) {});
    if (_res.containsKey("previews")) {
      List<Preview> _previewList = [];
      if ((_res["previews"] as List<dynamic>).isNotEmpty){
        List<Map<String, dynamic>>? _previews = List<Map<String, dynamic>>.from(_res["previews"]);
        _previews.forEach((Map<String, dynamic> json) => _previewList.add(Preview.fromJson(json)));
      }
      return {"previews": _previewList};
    }
    return _res;
  }
}