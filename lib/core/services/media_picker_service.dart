import 'package:image_picker/image_picker.dart';

abstract class MediaPickerService {
  /// Picks a single image from the specified source (gallery by default)
  /// Returns the local path to the picked image, or null if cancelled.
  Future<String?> pickImage({bool fromCamera = false});

  /// Picks multiple images from the gallery
  /// Returns a list of local paths to the picked images.
  Future<List<String>> pickMultipleImages();
}

class MediaPickerServiceImpl implements MediaPickerService {
  final ImagePicker _picker;

  MediaPickerServiceImpl({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  @override
  Future<String?> pickImage({bool fromCamera = false}) async {
    try {
      final source = fromCamera ? ImageSource.camera : ImageSource.gallery;
      final xFile = await _picker.pickImage(source: source);
      return xFile?.path;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<String>> pickMultipleImages() async {
    try {
      final xFiles = await _picker.pickMultiImage();
      return xFiles.map((f) => f.path).toList();
    } catch (e) {
      return [];
    }
  }
}
