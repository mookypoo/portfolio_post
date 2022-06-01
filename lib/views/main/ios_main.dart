import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../class/checkbox_class.dart';
import '../../providers/post_provider.dart';
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

class _IosMainState extends State<IosMain> with AutomaticKeepAliveClientMixin<IosMain> {

  @override
  Widget build(BuildContext context) {
    super.build(context); // 안해도 된뎁

    return Stack(
      children: <Widget>[
        CustomScrollView(
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
                        final PostsProvider _pp = Provider.of<PostsProvider>(ctx);
                        return CupertinoAlertDialog(
                          title: const Text("Categories", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18.0),),
                          content: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: _pp.viewCategories.map((CheckboxClass c) => IosCheckbox(data: c, onChanged: _pp.onCheckViewCat)).toList(),
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
              onRefresh: () async => await this.widget.postsProvider.getPreviews(),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate((BuildContext ctx, int index) {
                final PostsProvider _pp = Provider.of<PostsProvider>(ctx);
                  return PostPreviewTile(
                    getPost: _pp.getFullPost,
                    post: _pp.postPreviews[index],
                  );
                },
                childCount: context.watch<PostsProvider>().postPreviews.length,
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 0.0,
          right: 10.0,
          child: CupertinoButton(
            child: const Icon(CupertinoIcons.add_circled_solid, size: 55.0, color: MyColors.primary),
            onPressed: () async {
              this.widget.postsProvider.resetPost();
              await Navigator.of(context).pushNamed(NewPostPage.routeName, arguments: "새 글 작성하기",);
            },
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
