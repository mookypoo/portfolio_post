import '../class/comment_class.dart';
import '../class/post_class.dart';
import '../class/user_class.dart';
import '../repos/connect.dart';

class PostService {
  Connect _connect = Connect();

  Future<Map<String, dynamic>> getPreviews() async {
    try {
      final Map<String, dynamic> _res = await this._connect.reqGetServer(path: "/posts/getPreviews", cb: (ReqModel rm) {});
      if (_res.containsKey("previews")) {
        List<Preview> _previewList = [];
        if ((_res["previews"] as List<dynamic>).isNotEmpty){
          List<Map<String, dynamic>>? _previews = List<Map<String, dynamic>>.from(_res["previews"]);
          _previews.forEach((Map<String, dynamic> json) => _previewList.add(Preview.fromJson(json)));
        }
        return {"previews": _previewList};
      }
      if (_res.containsKey("error")) {
        // todo error handling
      }
    } catch (e) {
      print(e);
    }
    return {};
  }

  Future refreshPreviews() async {
    // todo refresh 할때 어떻게 하지???
  }

  // todo 질문: 이렇게 parameter 다 받아와서 여기서 body로 변경? 아니면 provider에서 부터 body로 변경해서 줌?
  Future<Map<String, dynamic>> addPost({String? filePath, required String? category, required String title, required String text, required Author author}) async {
    final Map<String, dynamic> _body = {
      "filePath": filePath,
      "title": title,
      "text": text,
      "author": author.toJson(),
      "category": category,
    };
    try {
      final Map<String, dynamic> _res = await this._connect.reqPostServer(path: "/posts/add", cb: (ReqModel rm) {}, body: {"post": _body});
      if (_res.containsKey("postUid") && _res.containsKey("createdTime")) return {
        "post": Post(createdTime: Post.convertISOToString( _res["createdTime"]), author: author, text: text, title: title, postUid: _res["postUid"], numOfLikes: 0, likedUsers: [], category: category),
        "preview": Preview(userName: author.userName, title: title, text: text, postUid: _res["postUid"], category: category),
      };
      return _res;
    } catch (e) {
      print(e);
    }
    return {};
  }

  Future<Map<String, dynamic>> getPost({required String postUid}) async {
    try {
      final Map<String, dynamic> _res = await this._connect.reqGetServer(
        path: "/posts/getPost/${postUid}", cb: (ReqModel rm) {}, );
      if (_res.containsKey("post")) {
        // todo put this conversion in class
        Map<String, dynamic> _post = _res["post"] as Map<String, dynamic>;
        if (_post["likedUsers"] != null) _post["likedUsers"] = List<String>.from(_post["likedUsers"]);
        return {"post": Post.fromJson(_res["post"] as Map<String, dynamic>)};
      }
      return _res;
    } catch (e) {
      print(e);
    }
    return {};
  }

  Future<Map<String, dynamic>> getComments({required String postUid}) async {
    try {
      final Map<String, dynamic> _res = await this._connect.reqGetServer(path: "/comments/get/${postUid}", cb: (ReqModel rm) {});
      if (_res.containsKey("comments")) {
        List<Comment> _commentsList = [];
        if (_res["comments"] == null) return {"comments": _commentsList};
        List<Map<String, dynamic>> _comments = List<Map<String, dynamic>>.from(_res["comments"]);
        _comments.forEach((Map<String, dynamic> json) => _commentsList.add(Comment.fromJson(json)));
        return {"comments": _commentsList};
      }
      return _res;
    } catch (e) {
      print(e);
    }
    return {};
  }

  Future<Map<String, dynamic>> like({required Post post, required String userUid}) async {
    final int _index = post.likedUsers.indexWhere((String uid) => userUid == uid);
    int _numOfLikes = post.numOfLikes;
    List<String> _likedUsers = post.likedUsers;
    final Map<String, dynamic> _body = {"postUid": post.postUid, "numOfLikes": _numOfLikes, "userUid": userUid};
    try {
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
    } catch (e) {
      print(e);
    }
    return {};
  }

  Future<Map<String, dynamic>> addComment({required CommentBody body, bool commentOnComment = false}) async {
    String _param = "comment";
    if (commentOnComment) _param = "commentOnComment";
    try {
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
    } catch (e) {
      print(e);
    }
    return {};
  }

  Future<Map<String, dynamic>> deletePost({required String postUid, required User user}) async {
    final Map<String, dynamic> _body = {"postUid": postUid, "userUid": user.userUid, "idToken": user.idToken};
    try {
      final Map<String, dynamic> _res = await this._connect.reqPostServer(path: "/posts/delete", cb: (ReqModel rm) {}, body: _body);
      return _res;
    } catch (e) {
      print(e);
    }
    return {};
  }

  // 여기까지 왔다는건 이미 verified 된건데 또 verify해야되나?
  Future<Map<String, dynamic>> editPost({required Map<String, dynamic> body}) async {
    try {
      final Map<String, dynamic> _res = await this._connect.reqPostServer(path: "/posts/edit", cb: (ReqModel rm) {}, body: body);
      return _res;
    } catch (e) {
      print(e);
    }
    return {};
  }

  Future uploadPhoto({required String postUid, required String filePath}) async {
    try {
      final _res = await this._connect.postImageServer(postUid: postUid, filePath: filePath, cb: (ReqModel rm) {});
      return _res;
    } catch (e) {
      print(e);
    }
  }


  Future<Map<String, dynamic>> categoryPreviews({required List<String> categories}) async {
    String query = "";
    categories.forEach((String s) => query += "category[]=$s&");
    query = query.substring(0, query.length - 1);
    try {
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
    } catch (e) {
      print(e);
    }
    return {};
  }

}