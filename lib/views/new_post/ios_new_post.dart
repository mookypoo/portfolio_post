import 'package:flutter/cupertino.dart';
import 'package:portfolio_post/views/new_post/common_components.dart';
import 'package:provider/provider.dart';

import '../../class/checkbox_class.dart';
import '../../class/photo_class.dart';
import '../../providers/post_provider.dart';
import '../../repos/variables.dart';
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
  final String _newText = "뒤로 가시면\n새로 작성한 글이 사라집니다.";
  final String _editText = "뒤로 가시면\n수정이 반영되지 않습니다.";
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
        final bool _goBack = await showCupertinoDialog(
          barrierDismissible: true,
          context: context,
          builder: (BuildContext ctx) => CupertinoAlertDialog(
            content: Container(
              padding: const EdgeInsets.only(top: 25.0, right: 10.0, bottom: 10.0, left: 10.0),
              height: 150.0,
              child: Text(_confirmText!, style: const TextStyle(fontSize: 17.0),),
            ),
            actions: <Widget>[
              CupertinoButton(
                child: const Text("뒤로가기", style: TextStyle(fontWeight: FontWeight.w500, color: CupertinoColors.black, fontSize: 15.5)),
                onPressed: () => Navigator.of(ctx).pop(true),
              ),
              CupertinoButton(
                child: const Text("머무르기", style: TextStyle(fontWeight: FontWeight.w600, color: MyColors.primary, fontSize: 15.5)),
                onPressed: () => Navigator.of(ctx).pop(false),
              ),
            ],
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
        child: CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text(this.widget.pageTitle),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              child: this.widget.pageTitle.contains("수정") ? const Icon(CupertinoIcons.floppy_disk) : const Icon(CupertinoIcons.add),
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
                                      children: this.widget.postsProvider.categories.map((CheckboxClass c) => IosCheckbox(
                                        data: c, onChanged: this.widget.postsProvider.onCheckWriteCat)).toList()
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
                          margin: const EdgeInsets.only(top: 25.0),
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
                          child: const Text("Add Image", style: TextStyle(color: MyColors.primary),),
                          onPressed: () async {
                            await showCupertinoDialog(
                              barrierDismissible: true,
                              context: context,
                              builder: (BuildContext ctx) {
                                final PostsProvider _pp = Provider.of<PostsProvider>(ctx);
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
                                          onTap: _pp.takePhoto,
                                        ),
                                        CameraGalleryButton(
                                          icon: CupertinoIcons.photo,
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
                        ...this.widget.postsProvider.newPhotos.map((String path) => new NewPhoto(
                          path: path, deleteNewPhoto: this.widget.postsProvider.deleteNewPhoto, icon: CupertinoIcons.delete)),
                        ...?this.widget.postsProvider.uploadedPhotos?.map((Photo photo) => new OldPhoto(
                          icon: CupertinoIcons.delete, deleteOldPhoto: this.widget.postsProvider.deleteOldPhoto, photo: photo,
                        )),
                      ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
