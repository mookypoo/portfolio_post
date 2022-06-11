import 'package:flutter/cupertino.dart';

import '../../providers/post_provider.dart';
import '../../providers/search_provider.dart';
import '../../providers/state_provider.dart' show ProviderState;
import '../loading/widget/loading_widget.dart';
import 'common_components.dart';

class IosSearch extends StatefulWidget {
  const IosSearch({Key? key, required this.searchProvider, required this.postsProvider, required this.state}) : super(key: key);
  final SearchProvider searchProvider;
  final PostsProvider postsProvider;
  final ProviderState state;

  @override
  State<IosSearch> createState() => _IosSearchState();
}

class _IosSearchState extends State<IosSearch> {
  final TextEditingController _ct = TextEditingController();

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
          transitionBetweenRoutes: false,
          middle: const Text("Search"),
          largeTitle: Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: CupertinoTextField(
              onSubmitted: (String? s) => this.widget.searchProvider.search(s!.trim()),
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
          delegate: SliverChildBuilderDelegate((BuildContext ctx, int index) {
            return Container(
              height: MediaQuery.of(context).size.height - 170.0,
              child: Center(child: Text("Sorry, there are no posts that match your search.")),
            );
          },
            childCount: this.widget.searchProvider.noResults ? 1 : 0,
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((BuildContext ctx, int index) {
            return this.widget.state == ProviderState.connecting
                ? LoadingWidget(height: MediaQuery.of(context).size.height - 150.0,)
                : SearchPostPreview(
              searchText: this._ct.text.trim(),
              post: this.widget.searchProvider.postPreviews[index],
              getPost: this.widget.postsProvider.getFullPost,
            );
          },
            childCount: this.widget.state == ProviderState.connecting ? 1 : this.widget.searchProvider.postPreviews.length,
          ),
        ),
      ],
    );
  }
}
