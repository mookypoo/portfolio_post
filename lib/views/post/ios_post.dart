import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../providers/post_provider.dart';
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
    MediaQueryData _mq = MediaQuery.of(context);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        transitionBetweenRoutes: false,
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
              minHeight: _mq.size.height - 66.0 - _mq.viewPadding.top - _mq.viewPadding.bottom,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                this.postsProvider.post?.author.userUid == this.postsProvider.user?.userUid
                  ? EditDelete(delete: this.postsProvider.deletePost, userUid: this.postsProvider.user!.userUid, resetPost: this.postsProvider.resetPost, initCategory: this.postsProvider.initCategory,)
                  : Container(),
                PostWidget(
                  state: this.postsProvider.state,
                  userUid: this.userProvider.user?.userUid ?? "",
                  post: this.postsProvider.post!,
                  follow: this.userProvider.follow,
                  isFollowing: this.userProvider.isFollowing(this.postsProvider.post!.author.userUid),
                  photos: this.postsProvider.uploadedPhotos,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
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
                    child: const Text("댓글 달기", style: const TextStyle(fontWeight: FontWeight.w600, color: MyColors.primary, fontSize: 15.0)),
                  ),
                ),
                this.postsProvider.comments.isNotEmpty
                  ? Comments(postsProvider: this.postsProvider)
                  : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
