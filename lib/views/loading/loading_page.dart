import 'dart:io';

import 'package:flutter/widgets.dart';

import 'android_loading.dart';
import 'ios_loading.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Platform.isAndroid
        ? AndroidLoading()
        : IosLoading();
  }
}
