import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/posts_provider.dart';
import '../../repos/variables.dart';
import 'android_components.dart';
import 'common_components.dart';

class AndroidPost extends StatelessWidget {
  const AndroidPost({Key? key, required this.postsProvider}) : super(key: key);
  final PostsProvider postsProvider;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(this.postsProvider.post?.title ?? ""),
        actions: [
          IconButton(
            padding: EdgeInsets.zero,
            icon: this.postsProvider.user == null ? Container() : !this.postsProvider.userLiked(this.postsProvider.user!.userUid) ? Icon(Icons.thumb_up_outlined) : Icon(Icons.thumb_up_alt_outlined),
            onPressed: this.postsProvider.user == null ? null : () async => await this.postsProvider.like(),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            this.postsProvider.post?.author.userUid == this.postsProvider.user!.userUid
                ? EditDelete(delete: this.postsProvider.deletePost, userUid: this.postsProvider.user!.userUid, resetPost: this.postsProvider.resetPost,)
                : Container(),
            PostWidget(post: this.postsProvider.post!),
            Container(
              margin: const EdgeInsets.only(top: 15.0),
              child: Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () async {
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
                        await this.postsProvider.addComment();
                      },
                      child: const Text("add comment", style: TextStyle(fontWeight: FontWeight.w600, color: MyColors.primary, fontSize: 15.0)),
                    ),
                  ),
                ],
              ),
            ),
            this.postsProvider.comments.isNotEmpty
                ? Comments(postsProvider: this.postsProvider,)
                : Container(),
          ],
        ),
      ),
    );
  }
}
