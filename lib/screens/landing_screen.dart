import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth_ui/constants.dart';
import 'package:flutter_firebase_auth_ui/providers/user_auth_provider.dart';
import 'package:flutter_firebase_auth_ui/utilities/global_navigation.dart';
import 'package:provider/provider.dart';

import '../utilities/enums.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  static final GlobalNavigation _navigation = GlobalNavigation();
  @override
  void initState() {
    checkAuthentication();
    super.initState();
  }

  void checkAuthentication() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userAuthProvider =
          Provider.of<UserAuthProvider>(context, listen: false);
      final FirebaseAuth auth = FirebaseAuth.instance;

      AuthStatus authStatus = await userAuthProvider.checkAuthState(
        uid: auth.currentUser?.uid,
      );

      navigate(authStatus: authStatus);
    });
  }

  void navigate({required AuthStatus authStatus}) {
    switch (authStatus) {
      case AuthStatus.authenticated:
        _navigation.navigateToReplacement(Constants.homeRoute);
        break;
      case AuthStatus.unauthenticated:
        _navigation.navigateToReplacement(Constants.signInRoute);
        break;
      case AuthStatus.authenticatedNoData:
        _navigation.navigateToReplacement(Constants.profileRoute);
        break;
      case AuthStatus.error:
        _navigation.navigateToReplacement(Constants.signInRoute);
        _navigation.showSnackBar(
          content: 'Error checking authentication, please try again',
          backgroundColor: Colors.red,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
