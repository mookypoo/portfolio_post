import 'package:image_picker/image_picker.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickImage() async => await _picker.pickImage(
    source: ImageSource.gallery,
    maxWidth: 300.0, maxHeight: 250.0, imageQuality: 80,
  );

  Future<XFile?> takePhoto() async => await _picker.pickImage(
    source: ImageSource.camera,
    maxWidth: 300.0, maxHeight: 250.0, imageQuality: 80,
  );

  Future<List<XFile>?> multipleImages() async => await _picker.pickMultiImage(
    maxWidth: 300.0, maxHeight: 250.0, imageQuality: 80,
  );
}