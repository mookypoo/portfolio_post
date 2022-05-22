import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart' show XFile;

import '../class/checkbox_class.dart';
import '../class/comment_class.dart';
import '../class/photo_class.dart';
import '../class/post_class.dart';
import '../class/preview_class.dart';
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

  List<Photo>? _uploadedPhotos;
  List<Photo>? get uploadedPhotos => [...?this._uploadedPhotos];
  set uploadedPhotos(List<Photo>? l) => throw "error";

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
    final PostBody _body = PostBody(text: text, author: this._author!, title: title, filePaths: this._newPhotos, category: this._categoryText());
    final Map<String, dynamic> _res = await this._postService.addPost(body: _body);
    if (_res.containsKey("preview")) {
      this._postPreviews.add(_res["preview"] as Preview);
      await this._getPost(_res["postUid"]);
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

  Future<void> getPostComments(String postUid) async {
    this.changeState(ProviderState.connecting);
    // todo error handling
    await this._getPost(postUid);
    await this._getComments(postUid);
    //List<bool> _res = await Future.wait<bool>([this._getPost(postUid), this._getComments(postUid)]);
    //if (_res.any((bool b) => b == false)) this.changeState(ProviderState.error);
    this.changeState(ProviderState.complete);
  }

  Future<bool> _getPost(String postUid) async {
    final Map<String, dynamic> _res = await this._postService.getPost(postUid: postUid);
    // todo 여기서 catch (e) 해서 dialog 보여줄 수 있나?
    if (_res.containsKey("post")) {
      this._post = _res["post"] as Post;

      //this._uploadedPhotos = this._post!.photos;
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

  Future<bool> _getPhotos(String postUid) async {

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
    this._categories = this._categories.map((CheckboxClass c) => CheckboxClass.reset(c)).toList();
    this.resetNewPhotos();
  }

  void resetNewPhotos(){
    this._newPhotos = [];
    this.notifyListeners();
  }

  Future<bool> editPost({required String text, required String title}) async {
    if (this._post == null || this._user == null) return false;
    final Map<String, dynamic> _body = this._user!.toJson()..addAll({
      "postUid": this._post!.postUid,
      "updateInfo": {"text": text, "title": title},
    });
    if (this._newPhotos.isNotEmpty) _body["filePaths"] = this._newPhotos;

    final Map<String, dynamic> _res = await this._postService.editPost(body: _body);
    if (_res.containsKey("modifiedTime")) {
      await this._getPost(this._post!.postUid);
      this._newPhotos = [];
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
    } else {
      // todo error handlig
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

  void deleteNewPhoto(String path){
    this._newPhotos.removeWhere((String p) => p == path);
    this.notifyListeners();
  }

  Future<void> deleteOldPhoto(Photo photo) async {
    if (this._post == null || this._user == null || this._uploadedPhotos == null) return;
    this._uploadedPhotos!.removeWhere((Photo p) => p.imageUid == photo.imageUid);
    this.notifyListeners();
    await this._postService.deletePhoto(user: this._user!, postUid: this._post!.postUid, photo: photo);
  }
}