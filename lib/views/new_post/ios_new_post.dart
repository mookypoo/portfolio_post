import 'package:flutter/cupertino.dart';
import 'package:portfolio_post/views/new_post/common_components.dart';
import 'package:provider/provider.dart';

import '../../class/checkbox_class.dart';
import '../../providers/post_provider.dart';
import '../components/ios_checkbox.dart';
import '../post/post_page.dart';

class IosNewPost extends StatefulWidget {
  const IosNewPost({Key? key, required this.postsProvider, required this.pageTitle}) : super(key: key);
  final PostsProvider postsProvider;
  final String pageTitle;

  @override
  State<IosNewPost> createState() => _IosNewPostState();
}

class _IosNewPostState extends State<IosNewPost> {
  final TextEditingController _titleCt = TextEditingController();
  final TextEditingController _textCt = TextEditingController();
  bool _isExpanded = false;

  @override
  void initState() {
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
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(this.widget.pageTitle),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(CupertinoIcons.add),
          onPressed: () async {
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
            Navigator.of(context).pop(PostPage.routeName);
          },
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
            child: this.widget.postsProvider.user == null
              ? Center(child: Text("로그인을 해야지 글을 쓸 수 있습니다."))
              : Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      child: Column(
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              this.setState(() {
                                this._isExpanded = !this._isExpanded;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 7.0),
                              child: const Text("Choose a Category", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18.0),),
                            ),
                          ),
                          this._isExpanded
                            ? Container(
                                child: Column(
                                    children: this.widget.postsProvider.categories.map((CheckboxClass c) => IosCheckbox(
                                      data: c, onChanged: this.widget.postsProvider.onCheckWrite)).toList()
                                ),
                              )
                            : Container()
                        ],
                      ),
                    ),
                    CupertinoTextField(
                      controller: this._titleCt,
                      placeholder: "Title",
                      decoration: const BoxDecoration(border: Border(bottom: BorderSide())),
                    ),
                    Container(
                      alignment: Alignment.topCenter,
                      margin: EdgeInsets.only(top: 25.0),
                      height: 500.0,
                      decoration: BoxDecoration(border: Border.all()),
                      child: CupertinoTextField(
                        controller: this._textCt,
                        maxLines: null,
                        placeholder: "Text",
                        decoration: const BoxDecoration(),
                      ),
                    ),
                    CupertinoButton(
                      child: Text("Add Image"),
                      onPressed: () async {
                        await showCupertinoDialog(
                          barrierDismissible: true,
                          context: context,
                          builder: (BuildContext context) {
                            PostsProvider _pp = Provider.of<PostsProvider>(context);
                            return CupertinoAlertDialog(
                              content: Container(
                                color: CupertinoColors.white,
                                width: 100.0,
                                height: 100.0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    CameraGalleryButton(
                                      icon: CupertinoIcons.camera,
                                      text: "Camera",
                                      onTap: _pp.getPhoto,
                                    ),
                                    CameraGalleryButton(
                                      icon: CupertinoIcons.photo,
                                      text: "Gallery",
                                      onTap: _pp.getPhoto,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    this.widget.postsProvider.photo!.existsSync()
                      ? Container(
                          padding: const EdgeInsets.all(15.0),
                          child: Image.file(this.widget.postsProvider.photo!, fit: BoxFit.cover),
                        )
                      : Container()
                  ],
            ),
          ),
        ),
      ),
    );
  }
}
