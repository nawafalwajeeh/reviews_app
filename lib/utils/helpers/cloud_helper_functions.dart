import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:reviews_app/localization/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Helper functions for cloud-related operations.
class AppCloudHelperFunctions {
  /// Helper function to check the state of a single database record.
  ///
  /// Returns a Widget based on the state of the snapshot.
  /// If data is still loading, it returns a CircularProgressIndicator.
  /// If no data is found, it returns a generic "No Data Found" message.
  /// If an error occurs, it returns a generic error message.
  /// Otherwise, it returns null.
  static Widget? checkSingleRecordState<T>(AsyncSnapshot<T> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!snapshot.hasData || snapshot.data == null) {
      return const Center(child: Text('No Data Found!'));
    }

    if (snapshot.hasError) {
      return const Center(child: Text('Something went wrong.'));
    }

    return null;
  }

  /// Helper function to check the state of multiple (list) database records.
  ///
  /// Returns a Widget based on the state of the snapshot.
  /// If data is still loading, it returns a CircularProgressIndicator.
  /// If no data is found, it returns a generic "No Data Found" message or a custom nothingFoundWidget if provided.
  /// If an error occurs, it returns a generic error message.
  /// Otherwise, it returns null.
  static Widget? checkMultiRecordState<T>({
    required AsyncSnapshot<List<T>> snapshot,
    Widget? loader,
    Widget? error,
    Widget? nothingFound,
  }) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      if (loader != null) return loader;
      return const Center(child: CircularProgressIndicator());
    }

    if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
      if (nothingFound != null) return nothingFound;
      // return const Center(child: Text('No Data Found!'));
      return Center(child: Text(AppLocalizations.of(Get.context!).noDataFound));
    }

    if (snapshot.hasError) {
      if (error != null) return error;
      // return const Center(child: Text('Something went wrong.'));
      return Center(
        child: Text(AppLocalizations.of(Get.context!).somethingWentWrong),
      );
    }

    return null;
  }

  /// Create a reference with an initial file path and name and retrieve the download URL.
  static Future<String> getURLFromFilePathAndName(String path) async {
    try {
      if (path.isEmpty) return '';
      final ref = FirebaseStorage.instance.ref().child(path);
      final url = await ref.getDownloadURL();
      return url;
    } on FirebaseException catch (e) {
      throw e.message!;
    } on PlatformException catch (e) {
      throw e.message!;
    } catch (e) {
      // throw 'Something went wrong.';
      throw AppLocalizations.of(Get.context!).somethingWentWrong;
    }
  }

  /// Create a public URL from a Supabase storage file path and name.
  static String getSupabasePublicUrl({
    required String bucketName,
    required String path,
    required String name,
  }) {
    try {
      if (path.isEmpty || name.isEmpty) return '';
      final filePath = '$path/$name';
      final url = Supabase.instance.client.storage
          .from(bucketName)
          .getPublicUrl(filePath);
      return url;
    } on PlatformException catch (e) {
      throw e.message!;
    } catch (e) {
      // throw 'Something went wrong.';
      throw AppLocalizations.of(Get.context!).somethingWentWrong;
    }
  }

  /// Retrieve the download URL from a given storage URI.
  static Future<String> getURLFromURI(String url) async {
    try {
      if (url.isEmpty) return '';
      final ref = FirebaseStorage.instance.refFromURL(url);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      throw e.message!;
    } on PlatformException catch (e) {
      throw e.message!;
    } catch (e) {
      // throw 'Something went wrong.';
      throw AppLocalizations.of(Get.context!).somethingWentWrong;
    }
  }

  /// Retrieve the public URL from a given Supabase storage URI.
  static Future<String> getURLFromSupabaseURI(
    String uri, {
    String bucketName = 'Images',
  }) async {
    try {
      if (uri.isEmpty) return '';
      // Extract the path after the bucket name
      // Example: uri = 'Images/Profile/image.png'
      final url = Supabase.instance.client.storage
          .from(bucketName)
          .getPublicUrl(uri);
      return url;
    } on PlatformException catch (e) {
      throw e.message!;
    } catch (e) {
      // throw 'Something went wrong.';
      throw AppLocalizations.of(Get.context!).somethingWentWrong;
    }
  }
}
