import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:portfolio_post/repos/variables.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({Key? key, this.height}) : super(key: key);
  final double? height;

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      alignment: Alignment.center,
      height: this.height ?? null,
      child: Platform.isAndroid
        ? const CircularProgressIndicator(
            color: MyColors.primary,
            strokeWidth: 2.5,
          )
        : CupertinoActivityIndicator(color: MyColors.primary),
    );
  }
}
