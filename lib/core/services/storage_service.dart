import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cross_file/cross_file.dart';

abstract class StorageService {
  /// Uploads a file from a local path and returns the download URL
  Future<String?> uploadFile({required String localPath, required String destinationPath});
  
  /// Uploads multiple files and returns their download URLs
  Future<List<String>> uploadMultipleFiles({required List<String> localPaths, required String folderPath});
}

class StorageServiceImpl implements StorageService {
  final FirebaseStorage _storage;

  StorageServiceImpl({FirebaseStorage? storage}) : _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<String?> uploadFile({required String localPath, required String destinationPath}) async {
    if (localPath.isEmpty) return null;
    try {
      final file = File(localPath);
      final ref = _storage.ref().child(destinationPath);
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<String>> uploadMultipleFiles({required List<String> localPaths, required String folderPath}) async {
    final urls = <String>[];
    var i = 0;
    for (final path in localPaths) {
      if (path.isEmpty) continue;
      try {
        final bytes = await XFile(path).readAsBytes();
        if (bytes.isEmpty) continue;
        final ref = _storage.ref().child('$folderPath/${DateTime.now().millisecondsSinceEpoch}_$i.jpg');
        await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
        urls.add(await ref.getDownloadURL());
        i++;
      } catch (e) {
        // Continue uploading remaining files even if one fails
        continue;
      }
    }
    return urls;
  }
}
