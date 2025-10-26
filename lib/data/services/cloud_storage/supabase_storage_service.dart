import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class AppSupabaseStorageService extends GetxController {
  static AppSupabaseStorageService get instance => Get.find();
  final supaBase = Supabase.instance.client;

  /// Upload Local Assets from IDE
  /// Returns a Uint8List containing image data.
  Future<Uint8List> getImageDataFromAssets(String path) async {
    try {
      final byteData = await rootBundle.load(path);
      final imageData = byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      );
      return imageData;
    } catch (e) {
      // Handle exceptions gracefully
      throw 'Error loading image data: $e';
    }
  }

  /// Upload Image using ImageData on Cloud Supabase Storage
  /// Returns the public download URL of the uploaded image.
  Future<String> uploadImageData(
    String path,
    Uint8List image,
    String name, {
    String bucketName = 'Images',
    bool createUniqueName = false,
  }) async {
    try {
      // 1. Read image from Uint8List
      // final fileName = '$path/$name';
      final fileName = createUniqueName
          ? '$path/${const Uuid().v4()}_$name'
          : '$path/$name';

      // 2. Upload the file to Supabase Storage
      final _ = await Supabase.instance.client.storage
          .from(bucketName)
          .uploadBinary(
            fileName,
            image,
            retryAttempts: 1,
            fileOptions: FileOptions(upsert: true),
          );

      // 3. Get the public URL of the uploaded image
      final url = Supabase.instance.client.storage
          .from(bucketName)
          .getPublicUrl(fileName);

      return url;
    } on StorageException catch (e) {
      throw 'Supabase Storage Error: ${e.message}';
    } on SocketException catch (e) {
      throw 'Network Error: ${e.message}';
    } on PlatformException catch (e) {
      throw 'Platform Exception: ${e.message}';
    } catch (e) {
      throw 'Failed to upload image after multiple retries: $e';
    }
  }

  /// Upload Image on Cloud Supabase Storage
  /// Returns the public download URL of the uploaded image.
  Future<String> uploadImageFile(
    String path,
    XFile image, {
    String bucketName = 'Images',
    bool createUniqueName = false,
  }) async {
    // use supaBase Storage
    try {
      // 1. Read image bytes
      // final fileName = '$path/${image.name}';
      final fileName = createUniqueName
          ? '$path/${const Uuid().v4()}_${image.name}'
          : '$path/${image.name}';

      final bytes = await image.readAsBytes();

      // 2. Upload the file to Supabase Storage
      final _ = await Supabase.instance.client.storage
          .from(bucketName)
          .uploadBinary(
            fileName,
            bytes,
            retryAttempts: 1,
            fileOptions: FileOptions(upsert: true),
          );

      // 3. Get the public URL of the uploaded image
      final url = Supabase.instance.client.storage
          .from(bucketName)
          .getPublicUrl(fileName);

      return url;
    } on StorageException catch (e) {
      throw 'Supabase Storage Error: ${e.message}';
    } on SocketException catch (e) {
      throw 'Network Error: ${e.message}';
    } on PlatformException catch (e) {
      throw 'Platform Exception: ${e.message}';
    } catch (e) {
      throw 'Failed to upload image after multiple retries: $e';
    }
  }
}
