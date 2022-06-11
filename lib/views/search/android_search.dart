import 'package:flutter/material.dart';
import 'package:portfolio_post/repos/variables.dart';

import '../../providers/post_provider.dart';
import '../../providers/search_provider.dart';
import '../../providers/state_provider.dart' show ProviderState;
import '../loading/widget/loading_widget.dart';
import 'common_components.dart';

class AndroidSearch extends StatefulWidget {
  const AndroidSearch({Key? key, required this.searchProvider, required this.postsProvider, required this.state}) : super(key: key);
  final SearchProvider searchProvider;
  final PostsProvider postsProvider;
  final ProviderState state;

  @override
  State<AndroidSearch> createState() => _AndroidSearchState();
}

class _AndroidSearchState extends State<AndroidSearch> {
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
        SliverAppBar(
          backgroundColor: MyColors.primary,
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Search"),
              Container(
                alignment: Alignment.bottomCenter,
                height: 40.0,
                margin: const EdgeInsets.only(top: 10.0),
                child: TextField(
                  onSubmitted: (String? s) => this.widget.searchProvider.search(s!.trim()),
                  controller: this._ct,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(left: 15.0, bottom: 0.0),
                    filled: true,
                    fillColor: MyColors.bg,
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: MyColors.bg),
                      borderRadius: BorderRadius.circular(25.0)
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: MyColors.bg),
                        borderRadius: BorderRadius.circular(25.0)
                    ),
                    suffixIcon: IconButton(
                      padding: const EdgeInsets.only(right: 5.0),
                      icon: const Icon(Icons.search),
                      onPressed: () => this.widget.searchProvider.search(this._ct.text.trim()),
                    ),
                  ),
                ),
              ),
            ],
          ),
          toolbarHeight: 100.0,
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
