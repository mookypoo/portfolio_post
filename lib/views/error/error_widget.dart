import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({Key? key, this.text}) : super(key: key);
  final String? text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(this.text ?? "Sorry, there was an error while loading the page.\nPlease try again later.", textAlign: TextAlign.center,),
    );
  }
}
