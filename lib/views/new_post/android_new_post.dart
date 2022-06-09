import 'package:flutter/material.dart';
import 'package:portfolio_post/views/components/android_checkbox.dart';
import 'package:portfolio_post/views/post/post_page.dart';
import 'package:provider/provider.dart';

import '../../class/checkbox_class.dart';
import '../../class/photo_class.dart';
import '../../providers/post_provider.dart';
import '../../repos/variables.dart';
import 'common_components.dart';

class AndroidNewPost extends StatefulWidget {
  const AndroidNewPost({Key? key, required this.postsProvider, required this.pageTitle}) : super(key: key);
  final PostsProvider postsProvider;
  final String pageTitle;

  @override
  State<AndroidNewPost> createState() => _AndroidNewPostState();
}

class _AndroidNewPostState extends State<AndroidNewPost> {
  final TextEditingController _titleCt = TextEditingController();
  final TextEditingController _textCt = TextEditingController();
  bool _isExpanded = false;
  final String _newText = "뒤로 가시면 새로 작성한 글이 사라집니다.";
  final String _editText = "뒤로 가시면 수정이 반영되지 않습니다.";
  String? _confirmText;

  @override
  void initState() {
    if (this.widget.pageTitle.contains("수정")) _confirmText = _editText;
    if (this.widget.pageTitle.contains("작성하기")) _confirmText = _newText;
    if (this.widget.postsProvider.post != null) {
      this._titleCt.text = this.widget.postsProvider.post!.title;
      this._textCt.text = this.widget.postsProvider.post!.text;
    }
    super.initState();
  }

  @override
  void dispose() {
    this._textCt.dispose();
    this._titleCt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final bool _goBack = await showDialog(
          barrierDismissible: true,
          context: context,
          builder: (BuildContext ctx) => Dialog(
            child: Container(
              padding: const EdgeInsets.only(top: 25.0, right: 15.0, bottom: 8.0, left: 15.0),
              height: 150.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(_confirmText!),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      TextButton(
                        child: const Text("뒤로가기", style: TextStyle(fontWeight: FontWeight.w400, color: Colors.black, fontSize: 15.5)),
                        onPressed: () => Navigator.of(ctx).pop(true),
                      ),
                      TextButton(
                        child: const Text("머무르기", style: TextStyle(fontWeight: FontWeight.w600, color: MyColors.primary, fontSize: 15.5)),
                        onPressed: () => Navigator.of(ctx).pop(false),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ) ?? false;
        if (_goBack) {
          this.widget.postsProvider.resetNewPhotos();
          return await true;
        }
        return await false;
      },
      child: GestureDetector(
        onTap: FocusManager.instance.primaryFocus?.unfocus,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: MyColors.primary,
            title: Text(this.widget.pageTitle),
            actions: [
              IconButton(
                padding: EdgeInsets.zero,
                icon: this.widget.pageTitle.contains("수정") ? const Icon(Icons.save) : const Icon(Icons.add),
                onPressed: () async {
                  if (this.widget.postsProvider.categoryText() == null) {
                    await showDialog(
                      barrierDismissible: true,
                      context: context,
                      builder: (BuildContext ctx) => AlertDialog(
                        content: const Text("Please choose a category", style: TextStyle(fontSize: 16.0),),
                        actions: <Widget>[
                          TextButton(
                            child: const Text("확인"),
                            onPressed: Navigator.of(ctx).pop,
                          )
                        ],
                      ),
                    );
                    return;
                  }
                  bool _success;
                  if (this.widget.postsProvider.post != null) {
                    _success = await this.widget.postsProvider.editPost(title: this._titleCt.text, text: this._textCt.text);
                  } else {
                    _success = await this.widget.postsProvider.addPost(
                      text: this._textCt.text,
                      title: this._titleCt.text,
                    );
                  }
                  if (!_success) return; // todo tell user "couldn't add post"
                  if (this.widget.pageTitle.contains("수정")) Navigator.of(context).pop(PostPage.routeName);
                  if (this.widget.pageTitle.contains("작성")) Navigator.of(context).popAndPushNamed(PostPage.routeName);
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
              child: this.widget.postsProvider.user == null
                ? Center(child: Text("로그인을 해야지 글을 쓸 수 있습니다."),)
                : Column(
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.only(bottom: 20.0),
                        child: Column(
                          children: <Widget>[
                            GestureDetector(
                              onTap: () => this.setState(() => this._isExpanded = !this._isExpanded),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 7.0),
                                child: const Text("Choose a Category", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18.0),),
                              ),
                            ),
                            this._isExpanded
                              ? Container(
                                  child: Column(
                                      children: this.widget.postsProvider.categories.map((CheckboxClass c) => new AndroidCheckbox(
                                          data: c, onChanged: this.widget.postsProvider.onCheckWriteCat)).toList()
                                  ),
                                )
                              : Container()
                          ],
                        ),
                      ),
                      TextField(
                        controller: this._titleCt,
                        cursorColor: MyColors.primary,
                        decoration: const InputDecoration(
                          constraints: const BoxConstraints(),
                          isDense: true,
                          contentPadding: const EdgeInsets.only(bottom: 5.0, left: 5.0),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: MyColors.primary, width: 1.5),
                          ),
                          border: const UnderlineInputBorder(),
                          focusColor: MyColors.primary,
                          hintText: "Title"
                        ),
                      ),
                      Container(
                        alignment: Alignment.topCenter,
                        margin: const EdgeInsets.only(top: 25.0),
                        height: 500.0,
                        decoration: BoxDecoration(border: Border.all()),
                        child: TextField(
                          controller: this._textCt,
                          maxLines: null,
                          cursorColor: MyColors.primary,
                          decoration: const InputDecoration(
                              contentPadding: const EdgeInsets.only(left: 10.0),
                              border: InputBorder.none,
                              hintText: "Text",
                            focusColor: MyColors.primary,
                          ),
                        ),
                      ),
                      TextButton(
                        child: const Text("Add Image", style: TextStyle(color: MyColors.primary),),
                        onPressed: () async {
                          await showDialog(
                            barrierDismissible: true,
                            context: context,
                            builder: (BuildContext ctx) {
                              final PostsProvider _pp = Provider.of<PostsProvider>(ctx);
                              return Dialog(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                                  color: Colors.white,
                                  width: 70.0,
                                  height: 100.0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      CameraGalleryButton(
                                        icon: Icons.camera,
                                        text: "Camera",
                                        onTap: _pp.takePhoto,
                                      ),
                                      CameraGalleryButton(
                                        icon: Icons.photo,
                                        text: "Gallery",
                                        onTap: _pp.selectPhotos,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      ...this.widget.postsProvider.newPhotos.map((Photo photo) => new PhotoWidget(
                          photo: photo, deletePhoto: this.widget.postsProvider.deleteNewPhoto, icon: Icons.delete)),
                      ...?this.widget.postsProvider.uploadedPhotos?.map((Photo photo) => new PhotoWidget(
                        icon: Icons.delete, deletePhoto: this.widget.postsProvider.deleteOldPhoto, photo: photo,
                      )),
                    ],
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
