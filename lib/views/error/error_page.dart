import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../providers/state_provider.dart';
import '../../repos/variables.dart';
import 'error_widget.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({Key? key, required this.stateProvider}) : super(key: key);
  final StateProvider stateProvider;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Platform.isAndroid
        ? Scaffold(appBar: AppBar(backgroundColor: MyColors.primary), body: CustomErrorWidget(text: this.stateProvider.error),)
        : CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(),
            child: SafeArea(child: CustomErrorWidget(text: this.stateProvider.error)),
          ),
      onWillPop: () async {
        this.stateProvider.changeState(state: ProviderState.open, error: null);
        return await true;
      },
    );
  }
}
