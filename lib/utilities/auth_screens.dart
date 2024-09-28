import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth_ui/constants.dart';
import 'package:flutter_firebase_auth_ui/models/user_model.dart';
import 'package:flutter_firebase_auth_ui/providers/user_auth_provider.dart';
import 'package:flutter_firebase_auth_ui/utilities/global_navigation.dart';
import 'package:flutter_firebase_auth_ui/utilities/enums.dart';
import 'package:flutter_firebase_auth_ui/utilities/file_upload_handler.dart';
import 'package:flutter_firebase_auth_ui/utilities/image_picker_handler.dart';
import 'package:flutter_firebase_auth_ui/widgets/user_image_avatar.dart';
import 'package:provider/provider.dart';

class AuthScreens {
  static final GlobalNavigation _navigation = GlobalNavigation();
  // build sign in screen
  static Widget buildSignInScreen(BuildContext context) {
    return SignInScreen(
      providers: FirebaseUIAuth.providersFor(FirebaseAuth.instance.app),
      actions: [
        _handleUserCreation(),
        _handleSignIn(context),
        _handlePhoneSignIn(context),
      ],
      headerBuilder: (context, constraints, shrinkOffset) {
        return _authHeaderLogo();
      },
      subtitleBuilder: (context, action) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: action == AuthAction.signIn
              ? const Text('Welcome to Flutter Firebase Auth, Please Sign In')
              : const Text('Welcome to Flutter Firebase Auth, Please Sign Up'),
        );
      },
      footerBuilder: (context, action) {
        return const Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text(
            'By signing in, you agree to our terms and conditions',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        );
      },
    );
  }

  // build email verification screen
  static Widget buildEmailVerificationScreen(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userAuthProvider =
        Provider.of<UserAuthProvider>(context, listen: false);
    return EmailVerificationScreen(
      headerBuilder: (context, constraints, shrinkOffset) => _authHeaderLogo(),
      actions: [
        EmailVerifiedAction(() {
          userAuthProvider
              .setUserModel(UserModel.initialModel(uid: user!.uid))
              .whenComplete(() {
            _navigation.navigateToReplacement(Constants.profileRoute);
          });
        }),
        AuthCancelledAction((context) {
          FirebaseUIAuth.signOut(context: context);
          _navigation.navigateToReplacement(Constants.signInRoute);
        })
      ],
    );
  }

  // build phone input screen
  static Widget buildPhoneInputScreen(BuildContext context) {
    return PhoneInputScreen(actions: [
      SMSCodeRequestedAction((context, action, flowKey, phoneNumber) {
        _navigation
            .navigateToReplacement(Constants.smsVerificationRoute, arguments: {
          'flowKey': flowKey,
          'action': action,
          'phone': phoneNumber,
        });
      }),
    ]);
  }

// build sms verification screen
  static Widget buildSMSVerificationScreen(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return SMSCodeInputScreen(
      actions: [
        _handleUserCreation(),
        _handlePhoneSignIn(context),
      ],
      flowKey: arguments['flowKey'],
      action: arguments['action'],
    );
  }

  // profile screen
  static Widget buildProfileScreen(BuildContext context) {
    return Consumer<UserAuthProvider>(
      builder: (context, userAuthProvider, _) {
        return ProfileScreen(
          appBar: AppBar(
            leading: const BackButton(),
            title: const Text('Profile'),
            centerTitle: true,
          ),
          avatar: UserImageAvatar(
            radius: 60.0,
            fileImage: userAuthProvider.fileImage,
            imageUrl: userAuthProvider.userModel!.imageUrl,
            onPressed: () {
              log('show image picker dialog');
              _handleAvatarPressed(context, userAuthProvider);
            },
          ),
          showDeleteConfirmationDialog: true,
          actions: [
            DisplayNameChangedAction((context, oldName, newName) {
              log('Display Name Changed');
              if (newName.isNotEmpty && newName.length >= 3) {
                // show loading dialog
                _navigation.showLoadingDialog('Saving...');

                // initialize user model
                final userModel = UserModel.initialModel(
                  uid: UserAuthProvider.currentUid()!,
                  name: newName,
                  phone: UserAuthProvider.currentUserPhone(),
                  email: UserAuthProvider.currentUserEmail(),
                );

                // save user data to firestore
                userAuthProvider.saveUserDataToFirestore(
                  currentUserModel: userModel,
                  onSuccess: () {
                    // dismiss loading dialog
                    _navigation.dismissDialog();

                    // navigate to Homee Screen
                    _navigation.navigateToReplacement(Constants.homeRoute);
                  },
                  onError: (error) {
                    // dismiss loading dialog
                    _navigation.dismissDialog();

                    // show error snackbar
                    _navigation.showSnackBar(
                      content: error,
                      backgroundColor: Colors.red,
                    );
                  },
                );
              } else {
                _navigation.showSnackBar(
                  content: 'Display Name must be at least 3 characters',
                  backgroundColor: Colors.red,
                );
              }
            }),
            SignedOutAction((context) {
              log('user signed out');
              _navigation.navigateToReplacement(Constants.signInRoute);
            })
          ],
        );
      },
    );
  }

  static Future<void> _handleAvatarPressed(
    BuildContext context,
    UserAuthProvider userAuthProvider,
  ) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final file = await ImagePickerHandler().showImagePickerDialog();

    if (file != null && context.mounted) {
      // set the file to file image in provider
      userAuthProvider.setFileImage(file);
      _navigation.showLoadingDialog('Saving...');

      // 1. save the image to firebase storage
      final imageUrl = await FileUploadHandler.updateUserImage(
        file: file,
        uid: uid,
        reference: '${Constants.profileImagesBucket}/$uid.jpg',
      );

      await userAuthProvider.updateUserImage(imageUrl);

      // 3. dismiss the dialog
      _navigation.dismissDialog();
    }
  }

  // handle user creation
  static AuthStateChangeAction<UserCreated> _handleUserCreation() {
    return AuthStateChangeAction<UserCreated>((context, state) {
      final UserCredential userCredential = state.credential;
      final User? user = userCredential.user;
      if (user == null) {
        return;
      }

      log('credential: $userCredential');
      // initialize sign in method
      SignInMethod signInMethod;

      // 1. check sign in method
      if (user.providerData.isNotEmpty) {
        final providerId = user.providerData.first.providerId;
        log('providerId: $providerId');
        switch (providerId) {
          case 'google.com':
            signInMethod = SignInMethod.google;
            break;
          case 'apple.com':
            signInMethod = SignInMethod.apple;
            break;
          case 'facebook.com':
            signInMethod = SignInMethod.facebook;
            break;
          case 'twitter.com':
            signInMethod = SignInMethod.twitter;
            break;
          case 'phone':
            signInMethod = SignInMethod.phone;
            break;
          default:
            signInMethod = SignInMethod.email;
            break;
        }
      } else {
        signInMethod = SignInMethod.email;
      }

      switch (signInMethod) {
        case SignInMethod.email:
          // navigate back to sign in screen
          _navigation.navigateToReplacement(Constants.signInRoute);

          // show snackbar
          _navigation.showSnackBar(
            content: 'User created successfully\nPlease Sign In',
            backgroundColor: Colors.green,
          );
          break;
        case SignInMethod.google:
        case SignInMethod.phone:
        case SignInMethod.facebook:
        case SignInMethod.twitter:
        case SignInMethod.apple:
          _handleUserFirestoreCheck(context, user);
          break;
      }
    });
  }

  // handle sign in
  static AuthStateChangeAction<SignedIn> _handleSignIn(BuildContext context) {
    return AuthStateChangeAction<SignedIn>((context, state) {
      if (!state.user!.emailVerified) {
        _navigation.navigateToReplacement(Constants.verifyEmailRoute);
      } else {
        // handle firebase check - check if user exist in firestore
        _handleUserFirestoreCheck(context, state.user!);
      }
    });
  }

  // handle sign in
  static AuthStateChangeAction<SignedIn> _handlePhoneSignIn(
      BuildContext context) {
    return AuthStateChangeAction<SignedIn>((context, state) {
      // get provider data
      final providerData = state.user!.providerData;

      // check if its a phone number sign in
      final isPhoneSignIn =
          providerData.any((provider) => provider.providerId == 'phone');

      if (isPhoneSignIn) {
        log('phone sign in');
        _handleUserFirestoreCheck(context, state.user!);
      }
    });
  }

  // handle user firestore check
  static Future<void> _handleUserFirestoreCheck(
    BuildContext context,
    User user,
  ) async {
    final userAuthProvider = context.read<UserAuthProvider>();
    bool userExists =
        await userAuthProvider.checkUserExistInFirestore(uid: user.uid);

    final providerData = user.providerData;

    if (userExists) {
      // get user data from firestore
      await userAuthProvider.getUserData();
      // navigate to home screen
      _navigation.navigateToReplacement(Constants.homeRoute);
    } else {
      // check if its a phone number sign in or email sign in
      final isPhoneOrEmail = providerData.any((provider) =>
          provider.providerId == 'phone' || provider.providerId == 'password');

      if (isPhoneOrEmail) {
        await userAuthProvider
            .setUserModel(UserModel.initialModel(uid: user.uid));
        // navigate to profile screen
        _navigation.navigateToReplacement(Constants.profileRoute);
      } else {
        log('uid: ${user.uid}');
        log('name: ${user.displayName}');
        // navigate to sign in screen
        _navigation.showLoadingDialog('Saving...');

        final userModel = UserModel.initialModel(
          uid: user.uid,
          name: user.displayName ?? 'Apple User',
          imageUrl: user.photoURL ?? '',
          phone: user.phoneNumber ?? '',
          email: user.email ?? '',
        );

        userAuthProvider.saveUserDataToFirestore(
          currentUserModel: userModel,
          onSuccess: () {
            _navigation.dismissDialog();
            _navigation.navigateToReplacement(Constants.homeRoute);
          },
          onError: () {
            // dismiss the dialog
            _navigation.dismissDialog();
            _navigation.showSnackBar(
              content: 'Something went wrong',
              backgroundColor: Colors.red,
            );
          },
        );
      }
    }
  }

  // auth header logo
  static Widget _authHeaderLogo() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Image.network(
            'https://firebase.flutter.dev/img/flutterfire_300x.png'),
      ),
    );
  }
}
