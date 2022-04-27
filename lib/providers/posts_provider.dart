import 'package:flutter/foundation.dart';

import '../class/comment_class.dart';
import '../class/post_class.dart';
import '../class/user_class.dart';
import '../service/post_service.dart';

enum ProviderState {
  open, connecting, complete, error
}

class PostsProvider with ChangeNotifier {
  PostService _postService = PostService();

  PostsProvider(){
    print("post provider init");
    this._getPreviews();
  }

  User? _user;
  User? get user => this._user;
  set user(User? u) => throw "error";

  Author? _author;

  ProviderState _state = ProviderState.open;
  ProviderState get state => this._state;
  set state(ProviderState s) => throw "error";

  List<Preview> _postPreviews = [];
  List<Preview> get postPreviews => [...this._postPreviews];
  set postPreviews(List<Preview> p) => throw "error";

  Post? _post;
  Post? get post => this._post;
  set post(Post? p) => throw "error";

  List<Comment> _comments = [];
  List<Comment> get comments => [...this._comments];
  set comments(List<Comment> c) => throw "error";

  String _comment = "";

  bool _isPrivate = false;
  bool get isPrivate => this._isPrivate;
  set isPrivate(bool b) => throw "error";

  void getUser(User user){
    this._user = user;
    this._author = Author(userName: user.userName, userUid: user.userUid);
  }

  void changeState(ProviderState state){
    this._state = state;
    this.notifyListeners();
  }

  Future<bool> addPost({required String title, required String text}) async {
    if (this._author == null) return false;
    final Map<String, dynamic> _res = await this._postService.addPost(text: text, title: title, author: this._author!);
    if (_res.containsKey("preview") && _res.containsKey("post")) {
      this._postPreviews.add(_res["preview"] as Preview);
      this._post = _res["post"] as Post;
      this.notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> _getPreviews() async {
    this.changeState(ProviderState.connecting);
    final Map<String, dynamic> _res = await this._postService.getPreviews();
    if (_res.containsKey("previews")) {
      this._postPreviews = _res["previews"];
      this.changeState(ProviderState.complete);
    } else {
      this.changeState(ProviderState.error);
    }
  }

  Future<void> getPostComments(String postUid) async {
    this.changeState(ProviderState.connecting);
    final bool _gotPost = await this._getPost(postUid);
    if (_gotPost) {
      final bool _gotComments = await this._getComments(postUid);
      if (_gotComments) this.changeState(ProviderState.complete);
    }
    this.changeState(ProviderState.error);
  }

  Future<bool> _getPost(String postUid) async {
    final Map<String, dynamic> _res = await this._postService.getPost(postUid: postUid);
    if (_res.containsKey("post")) {
      this._post = _res["post"] as Post;
      return true;
    }
    return false;
  }

  Future<bool> _getComments(String postUid) async {
    final Map<String, dynamic> _res = await this._postService.getComments(postUid: postUid);
    if (_res.isEmpty) {
      this._comments = [];
    }
    if (_res.containsKey("comments")) {
      this._comments = _res["comments"] as List<Comment>;
      return true;
    }
    return false;
  }

  bool userLiked(String userUid){
    if (this._post == null) return false;
    final int _index = this._post!.likedUsers.indexWhere((String uid) => userUid == uid);
    if (_index == -1) return false;
    return true;
  }

  Future<void> like() async {
    if (this._post == null || this._user == null) return;
    this.changeState(ProviderState.connecting);
    final int _index = this._post!.likedUsers.indexWhere((String uid) => this.user!.userUid == uid);
    int _numOfLikes = this._post!.numOfLikes;
    List<String> _likedUsers = [];
    Map<String, dynamic> _res;
    if (_index == -1) {
      _numOfLikes += 1;
      _likedUsers.add(this.user!.userUid);
      _res = await this._postService.like(postUid: this._post!.postUid, numOfLikes: _numOfLikes, userUid: this.user!.userUid);
    } else {
      _numOfLikes -= 1;
      _likedUsers.remove(this.user!.userUid);
      _res = await this._postService.unlike(postUid: this._post!.postUid, numOfLikes: _numOfLikes, userUid: this.user!.userUid);
    }
    if (_res.containsKey("data")) {
      this._post = Post.like(post: this._post!, numOfLikes: _numOfLikes, likedUsers: _likedUsers);
      this.changeState(ProviderState.complete);
    } else {
      this.changeState(ProviderState.error);
    }
  }

  void onComment(String s) => this._comment = s;

  // todo 질문 provider state
  Future<void> addComment() async {
    if (this._post == null || this._author == null) return;
    this.changeState(ProviderState.connecting);
    final Map<String, dynamic> _res = await this._postService.addComment(
        body: CommentBody(postUid: this.post!.postUid, text: this._comment, author: this._author!, isPrivate: this._isPrivate,
        ));
    if (_res.containsKey("comment")) {
      this._comments.add(_res["comment"] as Comment);
      this.changeState(ProviderState.complete);
    }
    this.changeState(ProviderState.error);
  }

  void changePrivate({bool? isPrivate}){
    if (isPrivate == null) this._isPrivate = !this._isPrivate;
    if (isPrivate != null) this._isPrivate = isPrivate;
    this.notifyListeners();
  }

  // todo delete parameter
  Future<bool> deletePost() async {
    if (this._post == null || this._user == null) return false;
    final Map<String, dynamic> _res = await this._postService.deletePost(postUid: this._post!.postUid, user: this._user!);
    if (_res.containsKey("deleted") && _res["deleted"]) {
      final int _index = this._postPreviews.indexWhere((Preview p) => p.postUid == this._post!.postUid);
      this._postPreviews.removeAt(_index);
      this.notifyListeners();
      return true;
    }
    return false;
  }

  void resetPost(){
    this._post = null; this._comments = [];
  }

  Future<bool> editPost({required String text, required String title}) async {
    if (this._post == null) return false;
    // todo only if title is different, only if text is different
    final Map<String, dynamic> _body = {
      "updateInfo": {"title": title, "text": text},
      "userUid": this._user!.userUid,
      "idToken": this._user!.idToken,
      "postUid": this._post!.postUid,
    };
    final Map<String, dynamic> _res = await this._postService.editPost(body: _body);
    if (_res.containsKey("modifiedTime")) {
      this._post = Post.edit(post: this._post!, text: text, title: title, modifiedTime: _res["modifiedTime"]);
      // todo todo only if title is different, only if first 100 characters of text is different
      final int _index = this._postPreviews.indexWhere((Preview p) => p.postUid == this._post!.postUid);
      this._postPreviews[_index] = Preview.edited(preview: this._postPreviews[_index], title: title, text: text);
      this.notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> commentOnComment({required String mainCommentUid}) async {
    if (this._post == null || this._author == null) return false;
    final Map<String, dynamic> _res = await this._postService.addComment(
      body: CommentBody(postUid: this._post!.postUid, text: this._comment, isPrivate: this._isPrivate, author: this._author!, mainCommentUid: mainCommentUid),
      commentOnComment: true,
    );
    if (_res.containsKey("comment")) {
      final int _index = this._comments.indexWhere((Comment c) => c.commentUid == mainCommentUid);
      this._comments[_index].comments.add(_res["comment"]);
      this.notifyListeners();
      return true;
    }
    return false;
  }
}