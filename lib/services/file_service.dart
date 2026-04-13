import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import '../utils/resource_type.dart';

class FileService {
  FileService._();

  static final Map<String, ResourceType> _extensionToType = {
    'pdf': ResourceType.pdf,
    'mp3': ResourceType.audio,
    'wav': ResourceType.audio,
    'ogg': ResourceType.audio,
    'mp4': ResourceType.video,
    'webm': ResourceType.video,
    'jpg': ResourceType.image,
    'jpeg': ResourceType.image,
    'png': ResourceType.image,
    'gif': ResourceType.image,
    'webp': ResourceType.image,
  };

  static Future<PlatformFile?> pickFile({
    List<String>? allowedExtensions,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
        withData: true,
      );
      return result?.files.first;
    } catch (e) {
      throw Exception('Failed to pick file: $e');
    }
  }

  static ResourceType detectFileType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    return _extensionToType[extension] ?? ResourceType.note;
  }

  static String getFileTypeFromExtension(String extension) {
    return extension.toLowerCase().replaceAll('.', '');
  }

  static bool isValidFileType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    return _extensionToType.containsKey(extension);
  }

  static String getFileSizeFormatted(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  static Uint8List? convertToUint8List(List<int>? data) {
    if (data == null) return null;
    if (data is Uint8List) return data;
    return Uint8List.fromList(data);
  }
}
