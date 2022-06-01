import 'package:image_picker/image_picker.dart';

import '../class/photo_class.dart';
import '../class/user_class.dart';
import '../repos/connect.dart';

class PhotoService {
  final ImagePicker _picker = ImagePicker();
  final Connect _connect = Connect();

  Future<XFile?> pickPhoto() async => await _picker.pickImage(
    source: ImageSource.gallery,
    maxWidth: 300.0, maxHeight: 250.0, imageQuality: 80,
  );

  Future<XFile?> takePhoto() async => await _picker.pickImage(
    source: ImageSource.camera,
    maxWidth: 300.0, maxHeight: 250.0, imageQuality: 80,
  );

  Future<List<XFile>?> multiplePhotos() async => await _picker.pickMultiImage(
    maxWidth: 300.0, maxHeight: 250.0, imageQuality: 80,
  );

  Future<Map<String, dynamic>> uploadPhoto({required User user, required String postUid, required List<String> filePaths}) async {
    print(filePaths);
    final Map<String, dynamic> _body = user.toJson()..addAll({ "filePaths": filePaths });
    final Map<String, dynamic> _res = await this._connect.reqPostServer(path: "/photos/upload/$postUid", body: _body);
    return _res;
  }

  Future<Map<String, dynamic>> getPhotos({required String postUid}) async {
    final Map<String, dynamic> _res = await this._connect.reqGetServer(path: "/photos/get/$postUid");
    if (_res.containsKey("photos")){
      List<Photo> _photos = [];
      if ((_res["photos"] as List).isNotEmpty) {
        final List<Map<String, dynamic>> _list = List<Map<String, dynamic>>.from(_res["photos"]);
        _list.forEach((Map<String, dynamic> data) => _photos.add(Photo.fromJson(data)));
      }
      return {"photos": _photos};
    }
    return _res;
  }

  Future<Map<String, dynamic>> deletePhoto({required User user, required String postUid, required Photo photo}) async {
    final Map<String, dynamic> _body = user.toJson()..addAll(photo.toJson());
    print(_body["fileName"]);
    final Map<String, dynamic> _res = await this._connect.reqPostServer(path: "/photos/delete/$postUid", body: _body);
    return _res;
  }
}