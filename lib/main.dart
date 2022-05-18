import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:portfolio_post/providers/auth_provider.dart';
import 'package:portfolio_post/providers/post_provider.dart';
import 'package:portfolio_post/providers/search_provider.dart';
import 'package:portfolio_post/providers/tab_provider.dart';
import 'package:portfolio_post/providers/user_provider.dart';
import 'package:portfolio_post/repos/variables.dart';
import 'package:portfolio_post/service/fcm_service.dart';
import 'package:portfolio_post/views/auth/auth_page.dart';
import 'package:portfolio_post/views/new_post/new_post_page.dart';
import 'package:portfolio_post/views/post/post_page.dart';
import 'package:portfolio_post/views/profile/profile_page.dart';
import 'package:portfolio_post/views/scaffold/scaffold_page.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FCMService.initializeFirebase();
  await FCMService.initializeLocalNotifications();
  await FCMService.onBackgroundMsg();
  await FCMService.onMessage();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
  runApp(const PortfolioPost());
}

class PortfolioPost extends StatelessWidget {
  const PortfolioPost({Key? key}) : super(key: key);

  Widget _androidApp() => MaterialApp(onGenerateRoute: (RouteSettings route) {
    if (route.name == NewPostPage.routeName) {
      final String _pageTitle = route.arguments.toString();
      return MaterialPageRoute(
        builder: (BuildContext context) => NewPostPage(),
        settings: RouteSettings(name: NewPostPage.routeName, arguments: _pageTitle),
      );
    };
    if (route.name == ProfilePage.routeName) {
      return MaterialPageRoute(
        builder: (BuildContext context) => ProfilePage(),
        settings: RouteSettings(name: ProfilePage.routeName),
      );
    };
    if (route.name == AuthPage.routeName) {
      return MaterialPageRoute<bool>(
        builder: (BuildContext context) => AuthPage(),
        settings: RouteSettings(name: AuthPage.routeName),
      );
    };
    if (route.name == PostPage.routeName) {
      return MaterialPageRoute(
        builder: (BuildContext context) => PostPage(),
        settings: RouteSettings(name: PostPage.routeName),
      );
    };
    return MaterialPageRoute(
      builder: (BuildContext context) => ScaffoldPage(),
      settings: RouteSettings(name: ScaffoldPage.routeName),
    );
  },
    home: ScaffoldPage(),
    theme: ThemeData(
      textTheme: TextTheme(
        bodyText2: TextStyle(fontSize: 17.0),
        button: TextStyle(color: MyColors.primary, fontSize: 17.0)
      ),
      iconTheme: IconThemeData(color: MyColors.primary),
    ),
  );

  Widget _iosApp() => CupertinoApp(
    theme: CupertinoThemeData(
      textTheme: CupertinoTextThemeData(
        textStyle: TextStyle(fontSize: 16.0, color: CupertinoColors.black),
      ),
    ),
    onGenerateRoute: (RouteSettings route) {
      if (route.name == NewPostPage.routeName) {
        final String _pageTitle = route.arguments.toString();
        return CupertinoPageRoute(
          builder: (BuildContext context) => NewPostPage(),
          settings: RouteSettings(name: NewPostPage.routeName, arguments: _pageTitle),
        );
      };
      if (route.name == AuthPage.routeName) {
        return CupertinoPageRoute<bool>(
          builder: (BuildContext context) => AuthPage(),
          settings: RouteSettings(name: AuthPage.routeName),
        );
      };
      if (route.name == PostPage.routeName) {
        return CupertinoPageRoute(
          builder: (BuildContext context) => PostPage(),
          settings: RouteSettings(name: PostPage.routeName),
        );
      };
      return CupertinoPageRoute(
        builder: (BuildContext context) => ScaffoldPage(),
        settings: RouteSettings(name: ScaffoldPage.routeName),
      );
    },
    home: ScaffoldPage(),
  );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<PostsProvider>(create: (_) => PostsProvider()),
        ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
        ChangeNotifierProvider<TabProvider>(create: (_) => TabProvider()),
        ChangeNotifierProvider<SearchProvider>(create: (_) => SearchProvider())
      ],
      child: Platform.isAndroid ? this._androidApp() : this._iosApp(),
    );
  }
}

/*
rules 에다가 다 false로 줘야됨 안그러면 다른사람이 postman같은거 서서 요청 보낼 수 있음

발행했던 토큰을 유저 아이디랑, 토믄이랑 저장? realtime에 => 따로 만드셈
이걸 나중에는 메디스라는 db를 통해 저장

사실은 사용자가 갖고 있는 값과 저장된 건 복구화 해야되는거라서 다름

복고화??
 */