import 'package:flutter/widgets.dart';
import 'package:portfolio_post/repos/variables.dart';

class NavBarWidget extends StatelessWidget {
  const NavBarWidget({Key? key, required this.icon, required this.isSelected, }) : super(key: key);
  final IconData icon;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    return Container(
      width: _size.width / 3,
      child: Icon(this.icon, size: 30.0, color: this.isSelected ? MyColors.primary : MyColors.grey,),
    );
  }
}

