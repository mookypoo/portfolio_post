import 'package:flutter/cupertino.dart';
import 'package:portfolio_post/views/profile/profile_page.dart';

import '../../class/nav_bar_class.dart';
import '../../providers/tab_provider.dart';
import '../../repos/variables.dart';
import '../main/main_page.dart';
import '../search/search_page.dart';
import 'common_components.dart';

class IosScaffold extends StatelessWidget {
  IosScaffold({Key? key, required this.tabProvider}) : super(key: key);
  final TabProvider tabProvider;

  final List<NavBarItem> _tabs = [
    NavBarItem(name: "Home", page: MainPage(), icon: CupertinoIcons.home),
    NavBarItem(name: "Search", page: SearchPage(), icon: CupertinoIcons.search),
    NavBarItem(name: "Profile", page: ProfilePage(), icon: CupertinoIcons.person),
  ];

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: FocusManager.instance.primaryFocus?.unfocus,
      child: CupertinoPageScaffold(
        child: Column(
          children: <Widget>[
            Expanded(
              child: this._tabs[this.tabProvider.selectedTab].page,
            ),
            Container(
              padding: EdgeInsets.only(bottom: 10.0),
              height: 66.0,
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
