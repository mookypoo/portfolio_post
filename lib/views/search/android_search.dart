import 'package:flutter/material.dart';
import 'package:portfolio_post/repos/variables.dart';

import '../../providers/post_provider.dart';
import '../../providers/search_provider.dart';
import 'common_components.dart';

class AndroidSearch extends StatefulWidget {
  const AndroidSearch({Key? key, required this.searchProvider, required this.postsProvider}) : super(key: key);
  final SearchProvider searchProvider;
  final PostsProvider postsProvider;

  @override
  State<AndroidSearch> createState() => _AndroidSearchState();
}

class _AndroidSearchState extends State<AndroidSearch> {
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
                  controller: this._ct,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(left: 15.0, bottom: 0.0),
                    filled: true,
                    fillColor: MyColors.bg,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: MyColors.bg),
                      borderRadius: BorderRadius.circular(25.0)
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: MyColors.bg),
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
