import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../class/comment_class.dart';
import '../../providers/posts_provider.dart';
import '../../repos/variables.dart';
import '../new_post/new_post_page.dart';

class EditDelete extends StatelessWidget {
  const EditDelete({Key? key, required this.delete, required this.userUid, required this.resetPost}) : super(key: key);
  final Future<bool> Function() delete;
  final String userUid;
  final void Function() resetPost;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        TextButton(
          child: const Text("Edit"),
          onPressed: () async => await Navigator.of(context).pushNamed(NewPostPage.routeName, arguments: "글 수정하기"),
        ),
        TextButton(
          child: const Text("Delete"),
          onPressed: () async {
            final bool _deleted = await this.delete();
            if (!_deleted) return; // todo error handling
            this.resetPost();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class CommentBottomSheet extends StatelessWidget {
  const CommentBottomSheet({Key? key, required this.isPrivate, required this.onComment, required this.changePrivate}) : super(key: key);
  final void Function(String s) onComment;
  final void Function() changePrivate;
  final bool isPrivate;

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    return Container(
      color: Colors.white,
      width: _size.width,
      height: 150.0,
      margin: MediaQuery.of(context).viewInsets,
      child: Column(
        children: <Widget>[
          TextButton(
            child: Text(!this.isPrivate ? "Make Private" : "Make Public"),
            onPressed: this.changePrivate,
          ),
          TextField(
            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(left: 15.0),
                hintText: "comment",
                border: InputBorder.none
            ),
            maxLines: null,
            onChanged: this.onComment,
          ),
          Row(
            children: <Widget>[
              Container(
                width: _size.width/2,
                child: TextButton(
                  child: const Text("Cancel"),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ),
              Container(
                width: _size.width/2,
                child: TextButton(
                  child: const Text("Save"),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Comments extends StatelessWidget {
  const Comments({Key? key, required this.postsProvider}) : super(key: key);
  final PostsProvider postsProvider;

  Widget _mainCommentWidget({required String text}){
    return Container(
      alignment: Alignment.centerLeft,
      height: 35.0,
      padding: const EdgeInsets.only(left: 10.0),
      decoration: BoxDecoration(border: Border.all()),
      child: Text(text),
    );
  }

  Widget _subWidget({required String text}){
    return Container(
      alignment: Alignment.centerLeft,
      height: 30.0,
      margin: const EdgeInsets.only(top: 5.0),
      padding: const EdgeInsets.only(left: 10.0, top: 5.0),
      decoration: BoxDecoration(border: Border.all()),
      child: Text(text, style: TextStyle(fontSize: 14.0),),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
          itemCount: this.postsProvider.comments.length,
          itemBuilder: (BuildContext context, int index) {
            final Comment _comment = this.postsProvider.comments[index];
            String _text = "${_comment.author.userName} : ${_comment.text}";
            if (_comment.isPrivate) {
              final String _secret = "${_comment.author.userName}: 비밀인 댓글입니다";
              if (this.postsProvider.user?.userUid != _comment.author.userUid
                  && this.postsProvider.user?.userUid != this.postsProvider.post?.author.userUid) _text = _secret;
            };
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  this._mainCommentWidget(text: _text),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("${_comment.createdTime}", style: TextStyle(fontSize: 13.5),),
                      GestureDetector(
                        child: Text("댓글달기", style: TextStyle(fontWeight: FontWeight.w600, color: MyColors.primary, fontSize: 15.0)),
                        onTap: () async {
                          final bool _save = await showModalBottomSheet<bool>(
                            context: context,
                            builder: (BuildContext ctx) {
                              PostsProvider _postsProvider = Provider.of<PostsProvider>(ctx);
                              return CommentBottomSheet(
                                isPrivate: _postsProvider.isPrivate,
                                onComment:  _postsProvider.onComment,
                                changePrivate: _postsProvider.changePrivate,
                              );
                            },
                          ) ?? false;
                          if (!_save) return;
                          final bool _success = await this.postsProvider.commentOnComment(mainCommentUid: this.postsProvider.comments[index].commentUid);
                          if (!_success) return;
                        },
                      ),
                    ],
                  ),
                  this.postsProvider.comments[index].comments.isNotEmpty
                    ? Container(
                        width: 300.0,
                        height: 45.0 * this.postsProvider.comments[index].comments.length,
                        child: ListView.builder(
                          itemCount: this.postsProvider.comments[index].comments.length,
                          itemBuilder: (BuildContext ctx, int i) {
                            final Comment _subComment = this.postsProvider.comments[index].comments[i];
                            String _text = "${_subComment.author.userName} : ${_subComment.text}";
                            if (_subComment.isPrivate) {
                              if (this.postsProvider.user?.userUid != _subComment.author.userUid
                                  && this.postsProvider.user?.userUid != this.postsProvider.post!.author.userUid) _text = "${_subComment.author.userName}: 비밀인 댓글입니다";
                            };
                            return this._subWidget(text: _text);
                          },
                        ),
                      )
                    : Container(),
                ],
              ),
            );
          }),
    );
  }
}