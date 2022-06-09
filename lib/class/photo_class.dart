import 'dart:typed_data';

class Photo {
  final String fileName;
  final Uint8List bytes;

  Photo({required this.fileName, required this.bytes});

  factory Photo.fromJson(Map<String, dynamic> json){
    final List<int> _bytes = List<int>.from(json["bytes"]["data"]);
    return Photo(
      bytes: Uint8List.fromList(_bytes),
      fileName: json["fileName"]
    );
  }

  Map<String, dynamic> toJson() => {"fileName": this.fileName, "bytes": this.bytes};

  static List<Map<String, dynamic>> photoListToJson(List<Photo> photos)
    => photos.map<Map<String, dynamic>>((Photo p) => p.toJson()).toList();
}
