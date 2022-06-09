import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart' show XFile;
import 'package:portfolio_post/providers/state_provider.dart';

import '../class/checkbox_class.dart';
import '../class/comment_class.dart';
import '../class/photo_class.dart';
import '../class/post_class.dart';
import '../class/preview_class.dart';
import '../class/user_class.dart';
import '../service/photo_service.dart';
import '../service/post_service.dart';

class PostsProvider with ChangeNotifier {
  final PostService _postService = PostService();
  final PhotoService _imageService = PhotoService();
  final StateProvider stateProvider;

  PostsProvider(this.stateProvider){
    print("post provider init");
    this.getPreviews();
  }

  ProviderState _state = ProviderState.open;
  ProviderState get state => this._state;
  set state(ProviderState s) => throw "error";

  List<CheckboxClass> _categories = [...PostService.categories];
  List<CheckboxClass> get categories => [...this._categories];
  set categories(List<CheckboxClass> s) => throw "error";

  List<CheckboxClass> _viewCategories = [...PostService.categories];
  List<CheckboxClass> get viewCategories => [...this._viewCategories];
  set viewCategories(List<CheckboxClass> s) => throw "error";

  User? _user;
  User? get user => this._user;
  set user(User? u) => throw "error";

  Author? _author;

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

  List<Photo> _newPhotos = [];
  List<Photo> get newPhotos => [...this._newPhotos];
  set newPhotos(List<Photo> l) => throw "error";

  List<Photo>? _uploadedPhotos;
  List<Photo>? get uploadedPhotos => [...?this._uploadedPhotos];
  set uploadedPhotos(List<Photo>? l) => throw "error";

  void getUser(User user){
    this._user = user;
    this._author = Author(userName: user.userName, userUid: user.userUid);
  }

  List<String> saveCategory(){
    List<String> _categories = [];
    this._viewCategories.forEach((CheckboxClass c) {
      if (c.isChecked) _categories.add(c.text);
    });
    return _categories;
  }

  String? categoryText(){
    final int _catIndex = this._categories.indexWhere((CheckboxClass c) => c.isChecked == true);
    String? _category;
    if (_catIndex != -1) _category = this._categories[_catIndex].text;
    return _category;
  }

  Future<bool> addPost({required String title, required String text}) async {
    if (this._author == null) return false;
    final PostBody _body = PostBody(text: text, author: this._author!, title: title, photos: this._newPhotos, category: this.categoryText());
    final Map<String, dynamic> _res = await this._postService.addPost(body: _body);
    if (_res.containsKey("preview")) {
      this._postPreviews.add(_res["preview"] as Preview);
      await this.getFullPost(_res["postUid"]);
      this.notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> getPreviews() async {
    final Map<String, dynamic> _res = await this._postService.getPreviews();
    if (_res.containsKey("error")) this.stateProvider.changeState(state: ProviderState.error, error: _res["error"].toString());
    if (_res.containsKey("previews")) {
      this._postPreviews = _res["previews"];
      this.notifyListeners();
    }
  }

  Future<void> getFullPost(String postUid) async {
    this.resetPost();
    this._getPost(postUid);
    this._getComments(postUid);
    this._getPhotos(postUid);
  }

  Future<void> _getPost(String postUid) async {
    final Map<String, dynamic> _res = await this._postService.getPost(postUid: postUid);
    if (_res.containsKey("error")) this.stateProvider.changeState(state: ProviderState.error, error: _res["error"].toString());
    if (_res.containsKey("post")) {
      this._post = _res["post"] as Post;
      this.notifyListeners();
    }
  }

  Future<void> _getComments(String postUid) async {
    final Map<String, dynamic> _res = await this._postService.getComments(postUid: postUid);
    if (_res.containsKey("comments")) this._comments = _res["comments"] as List<Comment>;
    this.notifyListeners();
  }

  void initCategory(){
    final int _index = this._categories.indexWhere((CheckboxClass c) => c.text == this._post!.category);
    if (_index != -1) this._categories[_index] = CheckboxClass.onTap(this._categories[_index]);
    this.notifyListeners();
  }

  void changeState(ProviderState state){
    this._state = state;
    this.notifyListeners();
  }

  Future<void> _getPhotos(String postUid) async {
    Map<String, dynamic> _res = {};
    Future.delayed(Duration(milliseconds: 1200), () {
      if (_res.isEmpty) this.changeState(ProviderState.connecting);
    });
    _res = await this._imageService.getPhotos(postUid: postUid);
    if (_res.containsKey("photos")) this._uploadedPhotos = _res["photos"] as List<Photo>;
    if (this._state == ProviderState.connecting) this.changeState(ProviderState.complete);
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
    if (_res.containsKey("error")) this.stateProvider.changeState(state: ProviderState.error, error: _res["error"].toString());
    if (_res.containsKey("post")) {
      this._post = _res["post"] as Post;
      this.notifyListeners();
    }
  }

  void onComment(String s) => this._comment = s;

  Future<void> addComment() async {
    if (this._post == null || this._author == null) return;
    final CommentBody _body = CommentBody(postUid: this.post!.postUid, text: this._comment, author: this._author!, isPrivate: this._isPrivate);
    final Map<String, dynamic> _res = await this._postService.addComment(body: _body);
    if (_res.containsKey("error")) this.stateProvider.changeState(state: ProviderState.error, error: _res["error"].toString());
    if (_res.containsKey("comment")) {
      this._comments.add(_res["comment"] as Comment);
      this.notifyListeners();
    }
  }

  void changePrivate(){
    this._isPrivate = !this._isPrivate;
    this.notifyListeners();
  }

  Future<bool> deletePost() async {
    if (this._post == null || this._user == null) return false;
    final Map<String, dynamic> _res = await this._postService.deletePost(postUid: this._post!.postUid, user: this._user!);
    if (_res.containsKey("error")) this.stateProvider.changeState(state: ProviderState.error, error: _res["error"].toString());
    if (_res.containsKey("deleted") && _res["deleted"]) {
      final int _index = this._postPreviews.indexWhere((Preview p) => p.postUid == this._post!.postUid);
      this._postPreviews.removeAt(_index);
      this.notifyListeners();
      return true;
    }
    return false;
  }

  void resetPost({bool resetCategories = true}){
    this._post = null; this._comments = []; this._uploadedPhotos = null;
    if (resetCategories) this._categories = this._categories.map((CheckboxClass c) => CheckboxClass.reset(c)).toList();
    this.resetNewPhotos();
  }

  void resetNewPhotos(){
    this._newPhotos = [];
    this.notifyListeners();
  }

  Future<bool> editPost({required String text, required String title}) async {
    if (this._post == null || this._user == null) return false;
    final Map<String, dynamic> _body = {...this._user!.toJson(), "postUid": this._post!.postUid, "updateInfo": {"text": text, "title": title}};
    if (this._newPhotos.isNotEmpty) await this._imageService.uploadPhoto(photos: this._newPhotos, user: this._user!);
    final Map<String, dynamic> _res = await this._postService.editPost(body: _body);
    if (_res.containsKey("error")) return false;
    if (_res.containsKey("modifiedTime")) {
      final int _index = this._postPreviews.indexWhere((Preview preview) => preview.postUid == this._post!.postUid);
      this._postPreviews[_index] = Preview.edit(category: this.categoryText(), oldPreview: this._postPreviews[_index], title: title, text: text.substring(0, text.length < 100 ? text.length : 100));
      await this.getFullPost(this._post!.postUid);
      this.resetNewPhotos();
    }
    return true;
  }

  Future<bool> commentOnComment({required String mainCommentUid}) async {
    if (this._post == null || this._author == null) return false;
    final Map<String, dynamic> _res = await this._postService.addComment(
      body: CommentBody(postUid: this._post!.postUid, text: this._comment, isPrivate: this._isPrivate, author: this._author!, mainCommentUid: mainCommentUid),
      commentOnComment: true,
    );
    if (_res.containsKey("error")) return false;
    if (_res.containsKey("comment")) {
      final int _index = this._comments.indexWhere((Comment c) => c.commentUid == mainCommentUid);
      this._comments[_index].comments.add(_res["comment"]);
      this.notifyListeners();
    }
    return true;
  }

  void onCheckViewCat(CheckboxClass c){
    final int _index = this._viewCategories.indexWhere((CheckboxClass ch) => ch.text == c.text);
    this._viewCategories[_index] = CheckboxClass.onTap(c);
    this.notifyListeners();
  }

  void onCheckWriteCat(CheckboxClass c){
    final int _prevIndex = this._categories.indexWhere((CheckboxClass ch) => ch.isChecked == true);
    if (_prevIndex != -1) this._categories[_prevIndex] = CheckboxClass.onTap(this._categories[_prevIndex]);
    final int _index = this._categories.indexWhere((CheckboxClass ch) => ch.text == c.text);
    this._categories[_index] = CheckboxClass.onTap(c);
    this.notifyListeners();
  }

  Future<void> getCategoryPreviews() async {
    if (this._viewCategories.every((CheckboxClass ch) => ch.isChecked == false)) {
      await this.getPreviews();
      return;
    }
    final Map<String, dynamic> _res = await this._postService.categoryPreviews(categories: this.saveCategory());
    if (_res.containsKey("error")) this.stateProvider.changeState(state: ProviderState.error, error: _res["error"].toString());
    if (_res.containsKey("previews")) this._postPreviews = _res["previews"];
    this.notifyListeners();
  }

  Future<void> takePhoto() async {
    final XFile? _xFile = await this._imageService.takePhoto();
    if (_xFile == null || this._post == null) return;
    final Photo _photo = await this._imageService.newPhoto(xFile: _xFile, postUid: this._post!.postUid);
    this._newPhotos.add(_photo);
    this.notifyListeners();
  }

  Future<void> selectPhotos() async {
    final List<XFile>? _xFiles = await this._imageService.multiplePhotos();
    if (_xFiles == null || this._post == null) return;
    _xFiles.forEach((XFile x) async {
      final Photo _photo = await this._imageService.newPhoto(xFile: x, postUid: this._post!.postUid);
      this._newPhotos.add(_photo);
    });
    this.notifyListeners();
  }

  void deleteNewPhoto(Photo photo){
    this._newPhotos.removeWhere((Photo p) => p.fileName == photo.fileName);
    this.notifyListeners();
  }

  Future<void> deleteOldPhoto(Photo photo) async {
    if (this._post == null || this._user == null || this._uploadedPhotos == null) return;
    final Map<String, dynamic> _res = await this._imageService.deletePhoto(user: this._user!, postUid: this._post!.postUid, photo: photo);
    if (_res.containsKey("data")) {
      this._uploadedPhotos!.removeWhere((Photo p) => p.fileName == photo.fileName);
      this.notifyListeners();
    }
  }
}