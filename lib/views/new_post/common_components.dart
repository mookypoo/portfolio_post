import 'dart:io';

import 'package:flutter/widgets.dart';

class CameraGalleryButton extends StatelessWidget {
  const CameraGalleryButton({Key? key, required this.icon, required this.text, required this.onTap}) : super(key: key);
  final IconData icon;
  final String text;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await this.onTap();
        Navigator.of(context).pop();
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Icon(this.icon, size: 35.0,),
          Text(this.text, style: const TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class NewPhoto extends StatelessWidget {
  const NewPhoto({Key? key, required this.path, required this.delete, required this.icon}) : super(key: key);
  final String path;
  final void Function(String path) delete;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Image.file(File(this.path), fit: BoxFit.contain, width: 280.0),
          GestureDetector(
            onTap: () => this.delete(this.path),
            child: Icon(this.icon, size: 20.0,),
          ),
        ],
      ),
    );
  }
}

