import 'package:flutter/cupertino.dart';

class IosWatermark extends StatelessWidget {
  const IosWatermark({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: Center(
        child: Image.asset(
          "assets/images/loading.gif",
          height: 125.0,
          width: 125.0,
        ),
      ),
    );
  }
}
