import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../class/checkbox_class.dart';
import '../../providers/post_provider.dart';
import '../../repos/variables.dart';
import '../components/android_checkbox.dart';
import '../new_post/new_post_page.dart';
import 'common_components.dart';

class AndroidMain extends StatefulWidget {
  const AndroidMain({Key? key, required this.postsProvider}) : super(key: key);

  final PostsProvider postsProvider;

  @override
  State<AndroidMain> createState() => _AndroidMainState();
}

class _AndroidMainState extends State<AndroidMain> with AutomaticKeepAliveClientMixin<AndroidMain>{
  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Stack(
      children: <Widget>[
        RefreshIndicator(
          displacement: 150.0,
          onRefresh: () async => await this.widget.postsProvider.getPreviews(),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                title: const Text("계시판", style: TextStyle(fontWeight: FontWeight.w500),),
                centerTitle: true,
                backgroundColor: MyColors.primary,
                actions: [
                  IconButton(
                    icon: Icon(Icons.more_vert_sharp),
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (BuildContext ctx) {
                          PostsProvider _pp = Provider.of<PostsProvider>(ctx);
                            return Dialog(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text("Categories", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18.0),),
                                    ..._pp.viewCategories.map((CheckboxClass c) => AndroidCheckbox(
                                        data: c, onChanged: _pp.onCheckView)).toList()
                                  ]
                              ),
                            ),
                          );
                        }
                      );
                      this.widget.postsProvider.getCategoryPreviews();
                    },
                  ),
                ],
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate((BuildContext ctx, int index) {
                  PostsProvider _pp = Provider.of<PostsProvider>(context);
                    return PostPreviewTile(
                      getPost: _pp.getPostComments,
                      post: _pp.postPreviews[index],
                    );
                  },
                  childCount: this.widget.postsProvider.postPreviews.length,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 15.0,
          right: 20.0,
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.add_circle_outlined, size: 55.0, color: MyColors.primary),
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