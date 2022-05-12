import 'package:flutter/widgets.dart';

class CameraGalleryButton extends StatelessWidget {
  const CameraGalleryButton({Key? key, required this.icon, required this.text, required this.onTap}) : super(key: key);
  final IconData icon;
  final String text;
  final Future<void> Function(String text) onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await this.onTap(this.text);
        Navigator.of(context).pop();
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(this.icon, size: 35.0,),
          Text(this.text, style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
