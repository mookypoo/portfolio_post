import 'package:flutter/cupertino.dart';

import '../../providers/posts_provider.dart';
import '../../repos/variables.dart';
import '../new_post/new_post_page.dart';
import '../profile/profile_page.dart';
import 'common_components.dart';

class IosMain extends StatelessWidget {
  const IosMain({Key? key, required this.postsProvider}) : super(key: key);

  final PostsProvider postsProvider;

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("계시판"),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () async => await Navigator.of(context).pushNamed(ProfilePage.routeName),
          child: Icon(CupertinoIcons.person),
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: <Widget>[
            CustomScrollView(
              slivers: [
                CupertinoSliverRefreshControl(
                  onRefresh: () async {
                    await this.postsProvider.refreshPreviews();
                  },
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate((BuildContext context, int index) => PostPreviewTile(
                      getPost: this.postsProvider.getPostComments,
                      post: this.postsProvider.postPreviews[index],
                    ),
                    childCount: this.postsProvider.postPreviews.length
                )),
              ],
            ),
            Positioned(
              bottom: 0.0,
              right: 10.0,
              child: CupertinoButton(
                child: const Icon(CupertinoIcons.add_circled_solid, size: 55.0, color: MyColors.primary),
                onPressed: () async {
                  this.postsProvider.resetPost();
                  await Navigator.of(context).pushNamed(
                    NewPostPage.routeName,
                    arguments: "새 글 쓰기",
                  );
                },
              ),
            ),
          ],
        )
      ),
    );
  }
}
