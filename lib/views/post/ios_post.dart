import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../providers/posts_provider.dart';
import '../../providers/user_provider.dart';
import '../../repos/variables.dart';
import 'common_components.dart';
import 'ios_components.dart';

class IosPost extends StatelessWidget {
  const IosPost({Key? key, required this.postsProvider, required this.userProvider}) : super(key: key);
  final PostsProvider postsProvider;
  final UserProvider userProvider;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(this.postsProvider.post?.title ?? ""),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: this.postsProvider.user == null ? Container() : !this.postsProvider.userLiked(this.postsProvider.user!.userUid) ? Icon(CupertinoIcons.hand_thumbsup) : Icon(CupertinoIcons.hand_thumbsup_fill),
          onPressed: this.postsProvider.user == null ? null : () async => await this.postsProvider.like(),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                this.postsProvider.post?.author.userUid == this.postsProvider.user?.userUid
                  ? EditDelete(delete: this.postsProvider.deletePost, userUid: this.postsProvider.user!.userUid, resetPost: this.postsProvider.resetPost,)
                  : Container(),
                PostWidget(
                  userUid: this.userProvider.user?.userUid ?? "",
                  post: this.postsProvider.post!,
                  follow: this.userProvider.follow,
                  isFollowing: this.userProvider.isFollowing(this.postsProvider.post!.author.userUid),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 15.0),
                  child: Column(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.centerRight,
                        child: CupertinoButton(
                          onPressed: () async {
                            final bool _save = await showCupertinoModalPopup<bool>(
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
                    ? Container(
                        child: Comments(postsProvider: this.postsProvider,),
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height,
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
