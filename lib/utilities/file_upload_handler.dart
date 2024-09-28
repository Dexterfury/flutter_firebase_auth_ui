import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_firebase_auth_ui/constants.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class FileUploadHandler {
  // upload file and get url
  static Future<String> uploadFileAndGetUrl({
    required File file,
    required String reference,
  }) async {
    try {
      // compress the image
      File compressedFile = await compressAndGetFile(
        file: file,
        targetPath: '${(await getTemporaryDirectory()).path}/image.jpg',
      );

      // upload the file to storage
      String downloadUrl = await storeFileToStorage(
        reference: reference,
        file: compressedFile,
      );

      return downloadUrl;
    } catch (e, stackTrace) {
      log(
        'Error uploading file',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  static Future<File> compressAndGetFile({
    required File file,
    required String targetPath,
  }) async {
    try {
      var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 90,
      );

      if (result == null) {
        throw Exception('Error compressing image');
      }

      return File(result.path);
    } catch (e, stackTrace) {
      log(
        'Error uploading file',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  static Future<String> storeFileToStorage({
    required String reference,
    required File file,
  }) async {
    try {
      if (!file.existsSync()) {
        throw Exception('File does not exist');
      }

      UploadTask uploadTask =
          FirebaseStorage.instance.ref().child(reference).putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e, stackTrace) {
      log(
        'Error uploading file',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // update user image in firestore
  static Future<String> updateUserImage({
    required File file,
    required String uid,
    required String reference,
  }) async {
    String imageUrl = '';

    try {
      final userDocRef = FirebaseFirestore.instance
          .collection(Constants.usersCollection)
          .doc(uid);

      final userDoc = await userDocRef.get();

      // check if the user document exists
      if (userDoc.exists) {
        imageUrl = await uploadFileAndGetUrl(
          file: file,
          reference: reference,
        );
        // update the user document with the new image URL
        await FirebaseAuth.instance.currentUser?.updatePhotoURL(imageUrl);
        userDocRef.update({Constants.imageUrl: imageUrl});
      }

      return imageUrl;
    } catch (e, stackTrace) {
      log(
        'Error uploading file',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
