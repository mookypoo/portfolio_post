import 'dart:typed_data';

class Photo {
  final String fileName;
  final Uint8List bytes;
  final String imageUid;

  Photo({required this.fileName, required this.bytes, required this.imageUid});

  factory Photo.fromJson(Map<String, dynamic> json){
    final List<int> _bytes = List<int>.from(json["bytes"]["data"]);
    return Photo(
      imageUid: json["imageUid"],
      bytes: Uint8List.fromList(_bytes),
      fileName: json["fileName"]
    );
  }

  Map<String, dynamic> toJson() => {
    "imageUid": this.imageUid,
    "fileName": this.fileName,
  };
}