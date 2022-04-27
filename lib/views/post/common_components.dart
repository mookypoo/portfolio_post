import 'package:flutter/widgets.dart';

import '../../class/post_class.dart' show Post;

class PostWidget extends StatelessWidget {
  const PostWidget({Key? key, required this.post}) : super(key: key);
  final Post post;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(this.post.title, style: TextStyle(fontWeight: FontWeight.w600, color: Color.fromRGBO(0, 0, 0, 1.0), fontSize: 20.0),),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
          child: Text(this.post.text, style: TextStyle()),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text("written by: ${this.post.author.userName}", style: TextStyle(fontSize: 15.0)),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text("likes: ${this.post.numOfLikes}", style: TextStyle(fontSize: 15.0)),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text("written: ${this.post.createdTime}", style: TextStyle(fontSize: 15.0)),
        ),
        this.post.modifiedTime != null ? Align(
          alignment: Alignment.centerRight,
          child: Text("last modified: ${this.post.modifiedTime}", style: TextStyle(fontSize: 15.0)),
        ) : Container(),
      ],
    );
  }
}

