import 'package:flutter/material.dart';

import '../../class/nav_bar_class.dart';
import '../../providers/tab_provider.dart';
import '../../repos/variables.dart';
import '../main/main_page.dart';
import '../profile/profile_page.dart';
import '../search/search_page.dart';
import 'common_components.dart';

class AndroidScaffold extends StatefulWidget {
  AndroidScaffold({Key? key, required this.tabProvider}) : super(key: key);
  final TabProvider tabProvider;

  @override
  State<AndroidScaffold> createState() => _AndroidScaffoldState();
}

class _AndroidScaffoldState extends State<AndroidScaffold> {
  final PageController _ct = PageController();

  final List<NavBarItem> _tabs = [
    NavBarItem(name: "Home", icon: Icons.home),
    NavBarItem(name: "Search", icon: Icons.search),
    NavBarItem(name: "Profile", icon: Icons.person),
  ];

  @override
  void dispose() {
    this._ct.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: FocusManager.instance.primaryFocus?.unfocus,
      child: Scaffold(
        body: Column(
          children: <Widget>[
            Expanded(
              child: PageView(
                controller: this._ct,
                onPageChanged: this.widget.tabProvider.changeTab,
                children: [
                  MainPage(),
                  SearchPage(),
                  ProfilePage(),
                ],
              ),
            ),
            Container(
              height: 52.0,
              width: _size.width,
              color: MyColors.bg,
              child: Row(
                children: this._tabs.map<Widget>((NavBarItem item) {
                  final int _index = this._tabs.indexOf(item);
                  return GestureDetector(
                    onTap: () {
                      this.widget.tabProvider.changeTab(_index);
                      this._ct.jumpToPage(_index);
                    },
                    child: NavBarWidget(
                      isSelected: _index == this.widget.tabProvider.selectedTab,
                      icon: item.icon,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}