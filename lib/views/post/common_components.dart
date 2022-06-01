import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:portfolio_post/repos/variables.dart';
import 'package:portfolio_post/views/loading/widget/loading_widget.dart';

import '../../class/photo_class.dart';
import '../../class/post_class.dart' show Post;
import '../../providers/state_provider.dart' show ProviderState;

class PostWidget extends StatelessWidget {
  const PostWidget({Key? key, required this.state, required this.userUid, required this.post, required this.follow, required this.isFollowing, required this.photos}) : super(key: key);
  final Post post;
  final Future<String?> Function(String postAuthorUid) follow;
  final bool? isFollowing;
  final String userUid;
  final List<Photo>? photos;
  final ProviderState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Align(
          alignment: Alignment.center,
          child: Text(this.post.title, style: const TextStyle(fontWeight: FontWeight.w600, color: Color.fromRGBO(0, 0, 0, 1.0), fontSize: 25.0),),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 20.0),
          alignment: Alignment.centerLeft,
          child: Text(this.post.text),
        ),
        ...?this.photos?.map((Photo photo) => new PhotoWidget(bytes: photo.bytes)),
        this.state == ProviderState.connecting ? LoadingWidget() : Container(),
        this.post.author.userUid == this.userUid ? Container() : Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text("written by: ${this.post.author.userName}", style: const TextStyle(fontWeight: FontWeight.w500),),
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
                style: const TextStyle(color: MyColors.primary, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text("좋아요: ${this.post.numOfLikes}", style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500)),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text("작성:   ${this.post.createdTime}", style: const TextStyle(fontSize: 15.0)),
        ),
        this.post.modifiedTime == null || this.post.modifiedTime!.isEmpty
          ? Container()
          : Align(
              alignment: Alignment.centerRight,
              child: Text("마지막 수정: ${this.post.modifiedTime}", style: const TextStyle(fontSize: 15.0)),
          )
      ],
    );
  }
}

class PhotoWidget extends StatelessWidget {
  const PhotoWidget({Key? key, required this.bytes}) : super(key: key);
  final Uint8List bytes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Image.memory(this.bytes, fit: BoxFit.contain, width: 280.0),
    );
  }
}
