import 'package:flutter/cupertino.dart';

class IosLoading extends StatelessWidget {
  const IosLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Center(
        child: CupertinoActivityIndicator(
          radius: 40.0,
          color: CupertinoColors.activeBlue,
        ),
      ),
    );
  }
}
