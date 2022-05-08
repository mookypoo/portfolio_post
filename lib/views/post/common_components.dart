import 'package:flutter/widgets.dart';
import 'package:portfolio_post/repos/variables.dart';

import '../../class/post_class.dart' show Post;

class PostWidget extends StatelessWidget {
  const PostWidget({Key? key,required this.userUid, required this.post, required this.follow, required this.isFollowing}) : super(key: key);
  final Post post;
  final Future<String?> Function(String postAuthorUid) follow; // todo  이거 문가 알아야될꺼같은데
  final bool? isFollowing;
  final String userUid;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Align(
          alignment: Alignment.center,
          child: Text(this.post.title, style: TextStyle(fontWeight: FontWeight.w600, color: Color.fromRGBO(0, 0, 0, 1.0), fontSize: 22.0),),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(this.post.text),
          ),
        ),
        this.post.author.userUid == this.userUid ? Container() : Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text("written by: ${this.post.author.userName}", style: TextStyle(fontWeight: FontWeight.w500),),
            GestureDetector(
              onTap: () async {
                final String? _result = await this.follow(this.post.author.userUid);
                if (_result == null) {
                  // server error occurred
                }
                // todo show snackbar / dialog
              },
              child: Text(
                this.isFollowing == null ? "" : this.isFollowing! ? "unfollow" : "follow",
                style: TextStyle(color: MyColors.primary, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text("좋아요: ${this.post.numOfLikes}", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500)),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text("작성: ${this.post.createdTime}", style: TextStyle(fontSize: 15.0)),
        ),
        this.post.modifiedTime == null || this.post.modifiedTime!.isEmpty
          ? Container()
          : Align(
              alignment: Alignment.centerRight,
              child: Text("last modified: ${this.post.modifiedTime}", style: TextStyle(fontSize: 15.0)),
            )
      ],
    );
  }
}

