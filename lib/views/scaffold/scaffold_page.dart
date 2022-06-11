import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:portfolio_post/views/scaffold/android_scaffold.dart';
import 'package:portfolio_post/views/scaffold/ios_scaffold.dart';
import 'package:portfolio_post/views/watermark/watermark_page.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../providers/state_provider.dart';
import '../../providers/tab_provider.dart';

class ScaffoldPage extends StatelessWidget {
  const ScaffoldPage({Key? key}) : super(key: key);
  static const String routeName = "/scaffoldPage";

  @override
  Widget build(BuildContext context) {
    final AuthProvider _authProvider = Provider.of<AuthProvider>(context, listen: false);
    final TabProvider _tabProvider = Provider.of<TabProvider>(context);
    final StateProvider _stateProvider = Provider.of<StateProvider>(context);
    final PostsProvider _postsProvider = Provider.of<PostsProvider>(context, listen: false);

    if (!_stateProvider.gotPreviews || !_stateProvider.gotUser) return WatermarkPage();

    return Platform.isAndroid
      ? AndroidScaffold(tabProvider: _tabProvider)
      : IosScaffold(tabProvider: _tabProvider,);
  }
}
