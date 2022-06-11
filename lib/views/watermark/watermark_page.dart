import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:portfolio_post/views/watermark/android_watermark.dart';
import 'package:portfolio_post/views/watermark/ios_watermark.dart';

class WatermarkPage extends StatelessWidget {
  const WatermarkPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Platform.isAndroid
      ? AndroidWatermark()
      : IosWatermark();
  }
}
