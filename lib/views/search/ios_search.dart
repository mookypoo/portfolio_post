import 'package:flutter/cupertino.dart';

import '../../providers/post_provider.dart';
import '../../providers/search_provider.dart';
import 'common_components.dart';

class IosSearch extends StatefulWidget {
  const IosSearch({Key? key, required this.searchProvider, required this.postsProvider}) : super(key: key);
  final SearchProvider searchProvider;
  final PostsProvider postsProvider;

  @override
  State<IosSearch> createState() => _IosSearchState();
}

class _IosSearchState extends State<IosSearch> {
  TextEditingController _ct = TextEditingController();

  @override
  void dispose() {
    this._ct.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        CupertinoSliverNavigationBar(
          middle: const Text("Search"),
          largeTitle: Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: CupertinoTextField(
              controller: this._ct,
              suffix: CupertinoButton(
                padding: const EdgeInsets.only(right: 5.0),
                child: const Icon(CupertinoIcons.search),
                onPressed: () => this.widget.searchProvider.search(this._ct.text.trim()),
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((BuildContext ctx, int index) => SearchPostPreview(
              searchText: this._ct.text.trim(),
              post: this.widget.searchProvider.postPreviews[index],
              getPost: this.widget.postsProvider.getPostComments,
            ),
            childCount: this.widget.searchProvider.postPreviews.length,
          ),
        ),
      ],
    );
  }
}
