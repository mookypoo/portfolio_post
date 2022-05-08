import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../class/checkbox_class.dart';
import '../../providers/posts_provider.dart';
import '../../repos/variables.dart';
import '../components/ios_checkbox.dart';
import '../new_post/new_post_page.dart';
import 'common_components.dart';

class IosMain extends StatefulWidget {
  const IosMain({Key? key, required this.postsProvider}) : super(key: key);
  final PostsProvider postsProvider;

  @override
  State<IosMain> createState() => _IosMainState();
}

class _IosMainState extends State<IosMain> with AutomaticKeepAliveClientMixin {
  ScrollController _ct = ScrollController();

  @override
  Widget build(BuildContext context) {
    super.build(context); // 안해도 된뎁
    return Stack(
      children: <Widget>[
        CustomScrollView(
          controller: this._ct,
          slivers: [
            CupertinoSliverNavigationBar(
              largeTitle: const Text("계시판"),
              trailing: CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(CupertinoIcons.ellipsis_vertical),
                onPressed: () async {
                  await showCupertinoDialog(
                    barrierDismissible: true,
                      context: context,
                      builder: (BuildContext ctx) {
                        PostsProvider _pp = Provider.of<PostsProvider>(ctx);
                        return CupertinoAlertDialog(
                          title: const Text("Categories", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18.0),),
                          content: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: _pp.viewCategories.map((CheckboxClass c) => IosCheckbox(
                                  data: c, onChanged: _pp.onCheckView)).toList(),
                            ),
                          ),
                        );
                      }
                  );
                  this.widget.postsProvider.getCategoryPreviews();
                },
              ),
            ),
            CupertinoSliverRefreshControl(
              refreshTriggerPullDistance: 150.0,
              onRefresh: () async => await this.widget.postsProvider.refreshPreviews(),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate((BuildContext ctx, int index) => PostPreviewTile(
                  getPost: this.widget.postsProvider.getPostComments,
                  post: this.widget.postsProvider.postPreviews[index],
                ),
                childCount: this.widget.postsProvider.postPreviews.length,
            )),
          ],
        ),
        Positioned(
          bottom: 0.0,
          right: 10.0,
          child: CupertinoButton(
            child: const Icon(CupertinoIcons.add_circled_solid, size: 55.0, color: MyColors.primary),
            onPressed: () async {
              this.widget.postsProvider.resetPost();
              await Navigator.of(context).pushNamed(NewPostPage.routeName, arguments: "새 글 쓰기",);

            },
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
