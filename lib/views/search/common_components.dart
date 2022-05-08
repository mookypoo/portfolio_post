import 'package:flutter/widgets.dart';

import '../../class/post_class.dart';
import '../../service/search_service.dart';
import '../post/post_page.dart';

class SearchPostPreview extends StatelessWidget {
  const SearchPostPreview({Key? key, required this.post, required this.getPost, required this.searchText}) : super(key: key);
  final Preview post;
  final Future<void> Function(String postUid) getPost;
  final String searchText;

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () async {
        Navigator.of(context).pushNamed(PostPage.routeName);
        await this.getPost(this.post.postUid);
      },
      child: Container(
        height: 150.0,
        margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            RichText(
              text: TextSpan(
                style: TextStyle(fontWeight: FontWeight.w600, color: Color.fromRGBO(255, 255, 255, 1.0), fontSize: 21.0),
                children: SearchService.highlightedText(searchText: this.searchText, text: this.post.title),
              ),
            ),
            RichText(
              maxLines: 4,
              softWrap: true,
              text: TextSpan(
                style: TextStyle(fontSize: 16.0, color: Color.fromRGBO(255, 255, 255, 1.0), overflow: TextOverflow.ellipsis),
                children: SearchService.highlightedText(searchText: this.searchText, text: this.post.text),
            )),
            Align(
              alignment: Alignment.centerRight,
              child: Text(this.post.userName, style: TextStyle(fontSize: 15.0)),
            ),
          ],
        ),
      ),
    );
  }
}
