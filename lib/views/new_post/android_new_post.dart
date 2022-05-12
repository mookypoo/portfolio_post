import 'package:flutter/material.dart';
import 'package:portfolio_post/views/components/android_checkbox.dart';
import 'package:portfolio_post/views/post/post_page.dart';

import '../../class/checkbox_class.dart';
import '../../providers/post_provider.dart';
import '../../repos/variables.dart';

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
    this.widget.postsProvider.resetPost();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusManager.instance.primaryFocus?.unfocus,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: MyColors.primary,
          title: Text(this.widget.pageTitle),
          actions: [
            IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.add),
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
                                    children: this.widget.postsProvider.viewCategories.map((CheckboxClass c) => AndroidCheckbox(
                                        data: c, onChanged: this.widget.postsProvider.onCheckView)).toList()
                                ),
                              )
                            : Container()
                        ],
                      ),
                    ),
                    TextField(
                      controller: this._titleCt,
                      decoration: InputDecoration(
                        constraints: BoxConstraints(),
                        isDense: true,
                        contentPadding: const EdgeInsets.only(bottom: 5.0, left: 5.0),
                        border: UnderlineInputBorder(),
                        hintText: "Title"
                      ),
                    ),
                    Container(
                      alignment: Alignment.topCenter,
                      margin: EdgeInsets.only(top: 25.0),
                      height: 500.0,
                      decoration: BoxDecoration(border: Border.all()),
                      child: TextField(
                        controller: this._textCt,
                        maxLines: null,
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(left: 10.0),
                            border: InputBorder.none,
                            hintText: "Text"
                        ),
                      ),
                    ),
                  ],
                ),
          ),
        ),
      ),
    );
  }
}
