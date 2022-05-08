import 'package:flutter/widgets.dart';

class NavBarItem {
  final String name;
  final Widget page;
  final IconData icon;

  NavBarItem({required this.name, required this.page, required this.icon});
}