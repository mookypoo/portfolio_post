import 'package:flutter/material.dart';

class AndroidWatermark extends StatelessWidget {
  const AndroidWatermark({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Image.asset(
          "assets/images/loading.gif",
          height: 125.0,
          width: 125.0,
        ),
      ),
    );
  }
}
