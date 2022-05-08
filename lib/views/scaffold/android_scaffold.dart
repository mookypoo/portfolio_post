import 'package:flutter/material.dart';

import '../../class/nav_bar_class.dart';
import '../../providers/tab_provider.dart';
import '../../repos/variables.dart';
import '../main/main_page.dart';
import '../profile/profile_page.dart';
import '../search/search_page.dart';
import 'common_components.dart';

class AndroidScaffold extends StatelessWidget {
  AndroidScaffold({Key? key, required this.tabProvider, required this.resetPost}) : super(key: key);
  final TabProvider tabProvider;
  final void Function() resetPost;

  final List<NavBarItem> _tabs = [
    NavBarItem(name: "Home", page: MainPage(), icon: Icons.home),
    NavBarItem(name: "Search", page: SearchPage(), icon: Icons.search),
    NavBarItem(name: "Profile", page: ProfilePage(), icon: Icons.person),
  ];

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: FocusManager.instance.primaryFocus?.unfocus,
      child: Scaffold(
        body: Column(
          children: <Widget>[
            Expanded(
              child: this._tabs[this.tabProvider.selectedTab].page,
            ),
            Container(
              height: 52.0,
              width: _size.width,
              color: MyColors.bg,
              child: Row(
                children: this._tabs.map<Widget>((NavBarItem item) {
                  final int _index = this._tabs.indexOf(item);
                  return GestureDetector(
                    onTap: () => this.tabProvider.changeTab(_index),
                    child: NavBarWidget(
                      isSelected: _index == this.tabProvider.selectedTab,
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