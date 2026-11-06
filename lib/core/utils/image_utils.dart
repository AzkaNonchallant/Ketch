import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageUtils {
  ImageUtils._();

  static final ImagePicker _picker = ImagePicker();

  // Mengambil gambar dari Kamera atau Galeri
  static Future<XFile?> pickImage(ImageSource source) async {
    return await _picker.pickImage(source: source, imageQuality: 85);
  }

  // Mengompres ukuran file gambar
  static Future<XFile?> compressImage(String targetPath, int quality) async {
    final compressedBytes = await FlutterImageCompress.compressAndGetFile(
      targetPath,
      '$targetPath.jpg',
      quality: quality,
    );
    return compressedBytes;
  }
}