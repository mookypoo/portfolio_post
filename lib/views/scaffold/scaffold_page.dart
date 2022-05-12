import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:portfolio_post/views/scaffold/android_scaffold.dart';
import 'package:portfolio_post/views/scaffold/ios_scaffold.dart';
import 'package:provider/provider.dart';

import '../../providers/post_provider.dart';
import '../../providers/tab_provider.dart';

class ScaffoldPage extends StatelessWidget {
  const ScaffoldPage({Key? key}) : super(key: key);
  static const String routeName = "/scaffoldPage";

  @override
  Widget build(BuildContext context) {
    TabProvider _tabProvider = Provider.of<TabProvider>(context);
    void Function() _resetPost = Provider.of<PostsProvider>(context, listen: false).resetPost;


    return Platform.isAndroid
      ? AndroidScaffold(tabProvider: _tabProvider, resetPost: _resetPost)
      : IosScaffold(tabProvider: _tabProvider,);
  }
}
