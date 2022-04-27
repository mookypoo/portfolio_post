import 'package:flutter/material.dart';

class AndroidLoading extends StatelessWidget {
  const AndroidLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CircularProgressIndicator(),
    );
  }
}
