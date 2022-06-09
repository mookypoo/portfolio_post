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

class PhotoWidget extends StatelessWidget {
  const PhotoWidget({Key? key, required this.icon, required this.photo, required this.deletePhoto}) : super(key: key);
  final IconData icon;
  final Photo photo;
  final void Function(Photo photo) deletePhoto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Image.memory(photo.bytes, fit: BoxFit.contain, width: MediaQuery.of(context).size.width * 0.7),
          GestureDetector(
            onTap: () => this.deletePhoto(this.photo),
            child: Icon(this.icon, size: 25.0,),
          ),
        ],
      ),
    );
  }
}

