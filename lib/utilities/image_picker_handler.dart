import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth_ui/utilities/global_navigation.dart';
import 'package:flutter_firebase_auth_ui/widgets/image_picker_item.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerHandler {
  static final GlobalNavigation _navigation = GlobalNavigation();

  Future<File?> showImagePickerDialog() async {
    Completer<File?> completer = Completer<File?>();

    await imagePickerDialog(
      context: _navigation.navigatorKey.currentContext!,
      title: 'Select Photo',
      content: 'Choose an Option',
      onPressed: (value) async {
        try {
          File? result = await selectImage(
              fromCamera: value,
              onError: (String error) {
                _navigation.showSnackBar(
                  content: error,
                  backgroundColor: Colors.red,
                );
              });

          if (result != null) {
            // Show loading dialog before cropping
            _navigation.showLoadingDialog('Preparing to crop...');
            File? croppedFile = await cropImage(
              filePath: result.path,
            );

            completer.complete(croppedFile);
          } else {
            completer.complete(null);
          }
        } catch (e) {
          completer.complete(null);
        }
      },
    );

    File? result = await completer.future;
    return result;
  }

  // seket an image
  Future<File?> selectImage({
    required bool fromCamera,
    required Function(String) onError,
  }) async {
    final filePicked = await pickUserImage(
        fromCamera: fromCamera,
        onError: (String error) {
          onError(error);
        });

    return filePicked;
  }

  // pick user image
  Future<File?> pickUserImage({
    required bool fromCamera,
    required Function(String) onError,
  }) async {
    File? result;
    if (fromCamera) {
      try {
        final pickedFile =
            await ImagePicker().pickImage(source: ImageSource.camera);
        if (pickedFile == null) {
          return onError(
            'No image selected',
          );
        } else {
          result = File(pickedFile.path);
        }
      } catch (e) {
        onError(e.toString());
      }
    } else {
      try {
        final pickedFile =
            await ImagePicker().pickImage(source: ImageSource.gallery);
        if (pickedFile == null) {
          return onError(
            'No image selected',
          );
        } else {
          result = File(pickedFile.path);
        }
      } catch (e) {
        onError(e.toString());
      }
    }

    return result;
  }

  Future<File?> cropImage({required String filePath}) async {
    _navigation.dismissDialog(); // Dismiss previous loading dialog
    _navigation.showLoadingDialog('Cropping image...');
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: filePath,
      maxHeight: 800,
      maxWidth: 800,
      compressQuality: 90,
    );

    _navigation.dismissDialog();

    if (croppedFile == null) {
      return null;
    }

    return File(croppedFile.path);
  }

  Future<void> imagePickerDialog({
    required BuildContext context,
    required String title,
    required String content,
    required Function(bool) onPressed,
  }) async {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (content, animation, animation2) {
        return Container();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.5, end: 1.0).animate(animation),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  content,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ImagePickerItem(
                      label: 'Camera',
                      iconData: Icons.camera_alt,
                      onPressed: () {
                        Navigator.pop(context);
                        onPressed(true);
                      },
                    ),
                    const SizedBox(
                      width: 24,
                    ),
                    ImagePickerItem(
                      label: 'Gallery',
                      iconData: Icons.photo,
                      onPressed: () {
                        Navigator.pop(context);
                        onPressed(false);
                      },
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
