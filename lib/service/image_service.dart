import 'package:image_picker/image_picker.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickImage() async => await _picker.pickImage(source: ImageSource.gallery);

  Future<XFile?> takePhoto() async => await _picker.pickImage(source: ImageSource.camera);

  Future<List<XFile>?> images() async => await _picker.pickMultiImage();
}