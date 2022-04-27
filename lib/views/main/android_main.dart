import 'package:flutter/material.dart';

import '../../providers/posts_provider.dart';
import '../../repos/variables.dart';
import '../new_post/new_post_page.dart';
import '../profile/profile_page.dart';
import 'common_components.dart';

class AndroidMain extends StatelessWidget {
  const AndroidMain({Key? key, required this.postsProvider}) : super(key: key);

  final PostsProvider postsProvider;

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("계시판"),
        actions: [
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: () async => await Navigator.of(context).pushNamed(ProfilePage.routeName),
            icon: Icon(Icons.person),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
              width: _size.width,
              height: _size.height,
              child: Container(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: this.postsProvider.postPreviews.length,
                  itemBuilder: (BuildContext context, int index) => PostPreviewTile(
                    getPost: this.postsProvider.getPostComments,
                    post: this.postsProvider.postPreviews[index],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0.0,
              right: 10.0,
              child: IconButton(
                icon: const Icon(Icons.add, size: 55.0, color: MyColors.primary),
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
        ),
      ),
    );
  }
}
