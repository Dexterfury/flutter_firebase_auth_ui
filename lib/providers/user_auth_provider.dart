import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth_ui/constants.dart';
import 'package:flutter_firebase_auth_ui/models/user_model.dart';
import 'package:flutter_firebase_auth_ui/utilities/enums.dart';
import 'package:flutter_firebase_auth_ui/utilities/file_upload_handler.dart';

class UserAuthProvider extends ChangeNotifier {
  File? _fileImage;
  UserModel? _userModel;

  // getters
  File? get fileImage => _fileImage;
  UserModel? get userModel => _userModel;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection(Constants.usersCollection);

  static String? currentUid() => FirebaseAuth.instance.currentUser?.uid;
  static String currentUserEmail() =>
      FirebaseAuth.instance.currentUser?.email ?? '';
  static String currentUserPhone() =>
      FirebaseAuth.instance.currentUser?.phoneNumber ?? '';

  // set file image
  void setFileImage(File file) {
    _fileImage = file;
    notifyListeners();
  }

  // update the user image
  Future<void> updateUserImage(String imageUrl) async {
    if (userModel != null) {
      _userModel!.imageUrl = imageUrl;
    }
    notifyListeners();
  }

  // set user model
  Future<void> setUserModel(UserModel userModel) async {
    _userModel = userModel;
    notifyListeners();
  }

  // get user data from firestore
  Future<void> getUserData() async {
    final snapshot = await _usersCollection.doc(currentUid()).get();
    if (snapshot.exists) {
      final userData = snapshot.data() as Map<String, dynamic>;
      final userModel = UserModel.fromJson(userData);
      setUserModel(userModel);
    }
  }

  // save user data to firestore
  Future<void> saveUserDataToFirestore({
    required UserModel currentUserModel,
    required Function onSuccess,
    required Function onError,
  }) async {
    try {
      if (fileImage != null) {
        // save image to firebase storage
        final imageUrl = await FileUploadHandler.uploadFileAndGetUrl(
          file: fileImage!,
          reference: '${Constants.profileImagesBucket}/${currentUid()}.jpg',
        );

        // update current user image
        currentUserModel.imageUrl = imageUrl;
        // update the user object image
        await _auth.currentUser!.updatePhotoURL(imageUrl);
      }

      // set the createdAt
      currentUserModel.createdAt =
          DateTime.now().millisecondsSinceEpoch.toString();

      // update the user model in provider
      _userModel = currentUserModel;

      // save user data to firestore
      await _firestore
          .collection(Constants.usersCollection)
          .doc(currentUserModel.uid)
          .set(currentUserModel.toJson());

      notifyListeners();
      onSuccess();
    } catch (e, stackTrace) {
      log(
        'Error saving user to firstore',
        error: e,
        stackTrace: stackTrace,
      );
      onError(e);
    }
  }

  // check authentication state
  Future<AuthStatus> checkAuthState({required String? uid}) async {
    try {
      if (uid != null) {
        bool userExists = await checkUserExistInFirestore(uid: uid);

        // check if user exists in firestore
        if (userExists) {
          // get user data from firestore
          await getUserData();
          return AuthStatus.authenticated;
        } else {
          await setUserModel(
            UserModel.initialModel(uid: uid),
          );
          return AuthStatus.authenticatedNoData;
        }
      } else {
        return AuthStatus.unauthenticated;
      }
    } catch (e, stackTrace) {
      log(
        'Error saving user to firstore',
        error: e,
        stackTrace: stackTrace,
      );
      return AuthStatus.unauthenticated;
    }
  }

  // check if user exists in firestore
  Future<bool> checkUserExistInFirestore({required String uid}) async {
    try {
      final snapshot = await _usersCollection.doc(uid).get();
      return snapshot.exists;
    } catch (e, stackTrace) {
      log(
        'Error saving user to firstore',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }
}
