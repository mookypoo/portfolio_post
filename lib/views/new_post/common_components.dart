import 'dart:io';
import 'package:flutter/widgets.dart';

import '../../class/photo_class.dart';

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
  const NewPhoto({Key? key, required this.path, required this.deleteNewPhoto, required this.icon}) : super(key: key);
  final String path;
  final void Function(String path) deleteNewPhoto;
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
            onTap: () => this.deleteNewPhoto(this.path),
            child: Icon(this.icon, size: 20.0,),
          ),
        ],
      ),
    );
  }
}

class OldPhoto extends StatelessWidget {
  const OldPhoto({Key? key, required this.icon, required this.photo, required this.deleteOldPhoto}) : super(key: key);
  final IconData icon;
  final Photo photo;
  final void Function(Photo photo) deleteOldPhoto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Image.memory(photo.bytes, fit: BoxFit.contain, width: 280.0),
          GestureDetector(
            onTap: () => this.deleteOldPhoto(this.photo),
            child: Icon(this.icon, size: 20.0,),
          ),
        ],
      ),
    );
  }
}

