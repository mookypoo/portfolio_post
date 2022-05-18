import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart' show XFile;

import '../class/checkbox_class.dart';
import '../class/comment_class.dart';
import '../class/post_class.dart';
import '../class/user_class.dart';
import '../service/image_service.dart';
import '../service/post_service.dart';

enum ProviderState {
  open, connecting, complete, error
}

class PostsProvider with ChangeNotifier {
  PostService _postService = PostService();
  ImageService _imageService = ImageService();

  PostsProvider(){
    print("post provider init");
    this.getPreviews();
  }

  // todo category도 uid줘서 다시 하기
  List<CheckboxClass> _categories = [
    CheckboxClass(text: "Firebase"),
    CheckboxClass(text: "Flutter"),
    CheckboxClass(text: "JavaScript"),
    CheckboxClass(text: "Node.js"),
    CheckboxClass(text: "Miscellaneous"),
  ];
  List<CheckboxClass> get categories => [...this._categories];
  set categories(List<CheckboxClass> s) => throw "error";

  List<CheckboxClass> _viewCategories = [
    CheckboxClass(text: "Firebase"),
    CheckboxClass(text: "Flutter"),
    CheckboxClass(text: "JavaScript"),
    CheckboxClass(text: "Node.js"),
    CheckboxClass(text: "Miscellaneous"),
  ];
  List<CheckboxClass> get viewCategories => [...this._viewCategories];
  set viewCategories(List<CheckboxClass> s) => throw "error";

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

  List<String> _newPhotos = [];
  List<String> get newPhotos => [...this._newPhotos];
  set newPhotos(List<String> l) => throw "error";

  // try multiple photos
  File? _newPhoto;
  File? get newPhoto => this._newPhoto;
  set newPhoto(File? x) => throw "error";

  void getUser(User user){
    this._user = user;
    this._author = Author(userName: user.userName, userUid: user.userUid);
  }

  void changeState(ProviderState state){
    this._state = state;
    this.notifyListeners();
  }

  List<String> saveCategory(){
    List<String> _categories = [];
    this._viewCategories.forEach((CheckboxClass c) {
      if (c.isChecked) _categories.add(c.text);
    });
    return _categories;
  }

  String? _categoryText(){
    final int _catIndex = this._categories.indexWhere((CheckboxClass c) => c.isChecked == true);
    String? _category;
    if (_catIndex != -1) _category = this._categories[_catIndex].text;
    return _category;
  }

  Future<bool> addPost({required String title, required String text}) async {
    if (this._author == null) return false;

    // todo 여기 parameter뭔가 더 간략하게 할 수 있을 듯 - text, title, author, category, filePath --> filepath 다시 하셈
    final Map<String, dynamic> _res = await this._postService.addPost(text: text, title: title, author: this._author!, category: this._categoryText(), filePath: this._newPhoto!.readAsBytesSync().toString() );
    if (_res.containsKey("preview") && _res.containsKey("post")) {
      this._postPreviews.add(_res["preview"] as Preview);
      this._post = _res["post"] as Post;
      // todo filepath
      this.notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> getPreviews() async {
    final Map<String, dynamic> _res = await this._postService.getPreviews();
    if (_res.containsKey("previews")) {
      this._postPreviews = _res["previews"];
      this.notifyListeners();
    } else {
      this.changeState(ProviderState.error);
    }
  }

  // todo 다른대도 multiple await 쓰면 이걸로 바꾸셈
  Future<void> getPostComments(String postUid) async {
    this.changeState(ProviderState.connecting);
    // todo 그냥 해도 됨?!?!?!?!  thread (native임) - isolate (flutter) --> 속도가 떨어짐?!?!
    // android native는 http request를 다른 thread 만들어서 함
    await this._getPost(postUid);
    await this._getComments(postUid);
    //List<bool> _res = await Future.wait<bool>([this._getPost(postUid), this._getComments(postUid)]);
    //if (_res.any((bool b) => b == false)) this.changeState(ProviderState.error);
    this.changeState(ProviderState.complete);
  }

  Future<bool> _getPost(String postUid) async {
    final Map<String, dynamic> _res = await this._postService.getPost(postUid: postUid);
    if (_res.containsKey("post")) {
      this._post = _res["post"] as Post;
      if (this._post?.filePaths != null) print("has file");
      return true;
    }
    return false;
  }

  Future<bool> _getComments(String postUid) async {
    final Map<String, dynamic> _res = await this._postService.getComments(postUid: postUid);
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
    final Map<String, dynamic> _res = await this._postService.like(post: this._post!, userUid: this.user!.userUid);
    if (_res.containsKey("post")) {
      this._post = _res["post"] as Post;
      this.notifyListeners();
    } else {
      // todo error handling
    }
  }

  void onComment(String s) => this._comment = s;

  Future<void> addComment() async {
    if (this._post == null || this._author == null) return;
    final Map<String, dynamic> _res = await this._postService.addComment(
        body: CommentBody(postUid: this.post!.postUid, text: this._comment, author: this._author!, isPrivate: this._isPrivate,
    ));
    if (_res.containsKey("comment")) {
      this._comments.add(_res["comment"] as Comment);
      this.notifyListeners();
    } else {
      // todo error handling
    }
  }

  void changePrivate(){
    this._isPrivate = !this._isPrivate;
    this.notifyListeners();
  }

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
    this._categories = this._viewCategories.map((CheckboxClass c) => CheckboxClass.reset(c)).toList();
    this.notifyListeners();
  }

  Future<bool> editPost({required String text, required String title}) async {
    if (this._post == null || this._user == null) return false;

    final Map<String, dynamic> _body = this._user!.toJson()..addAll({
      "postUid": this._post!.postUid,
      "updateInfo": {"text": text, "title": title},
    });

    print("new photos: ${this._newPhotos}");
    if (this._newPhotos.isNotEmpty) _body["filePaths"] = this._newPhotos;
    // if (this._newPhoto != null) {
    //   _body["filePath"] = this._newPhoto!.path;
    //   _body["fileName"] = this._newPhoto!.path.split("/").last;
    // }

    final Map<String, dynamic> _res = await this._postService.editPost(body: _body);
    if (_res.containsKey("modifiedTime")) {
      this._post = Post.edit(category: this._categoryText(), post: this._post!, text: text, title: title, modifiedTime: _res["modifiedTime"]);
      this.notifyListeners();
      return true;
    }
    return false;
    // todo 하고서 refresh preview 하셈, category null
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

  void onCheckView(CheckboxClass c){
    final int _index = this._viewCategories.indexWhere((CheckboxClass ch) => ch.text == c.text);
    this._viewCategories[_index] = CheckboxClass.onTap(c);
    this.notifyListeners();
  }

  void onCheckWrite(CheckboxClass c){
    final int _prevIndex = this._categories.indexWhere((CheckboxClass ch) => ch.isChecked == true);
    if (_prevIndex != -1) this._categories[_prevIndex] = CheckboxClass.onTap(this._categories[_prevIndex]);
    final int _index = this._categories.indexWhere((CheckboxClass ch) => ch.text == c.text);
    this._categories[_index] = CheckboxClass.onTap(c);
    this.notifyListeners();
  }

  Future<void> getCategoryPreviews() async {
    if (this._viewCategories.every((CheckboxClass ch) => ch.isChecked == false)) return;
    final Map<String, dynamic> _res = await this._postService.categoryPreviews(categories: this.saveCategory());
    if (_res.containsKey("previews")){
      this._postPreviews = _res["previews"];
      this.notifyListeners();
    }
  }

  Future<void> takePhoto() async {
    final XFile? _xFile = await this._imageService.takePhoto();
    if (_xFile == null) return;
    this._newPhotos.add(_xFile.path);
    this.notifyListeners();
  }

  Future<void> selectPhotos() async {
    final List<XFile>? _xFiles = await this._imageService.multipleImages();
    if (_xFiles == null) return;
    _xFiles.forEach((XFile x) => this._newPhotos.add(x.path));
    this.notifyListeners();
  }

  // for non-uploaded photos, newly added
  void deletePhoto(String path){
    this._newPhotos.removeWhere((String p) => p == path);
    this.notifyListeners();
  }

}