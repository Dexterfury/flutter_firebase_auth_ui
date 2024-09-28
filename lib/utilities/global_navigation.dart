import 'package:flutter/material.dart';

class GlobalNavigation {
  static final GlobalNavigation _instance = GlobalNavigation._internal();
  factory GlobalNavigation() => _instance;
  GlobalNavigation._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // get current context
  BuildContext get currentContext => navigatorKey.currentContext!;

  // navigate to route
  Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!
        .pushNamed(routeName, arguments: arguments);
  }

  // navigate to replacement
  Future<dynamic> navigateToReplacement(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!
        .pushReplacementNamed(routeName, arguments: arguments);
  }

  // pop
  void pop([dynamic result]) {
    return navigatorKey.currentState!.pop(result);
  }

  // show snackbar
  void showSnackBar({required String content, Color? backgroundColor}) {
    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
      SnackBar(
        content: Text(
          content,
          textAlign: TextAlign.center,
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: backgroundColor ?? Colors.black,
      ),
    );
  }

  // show loading dialog
  void showLoadingDialog(String message) {
    showDialog(
        context: navigatorKey.currentContext!,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
              content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 10),
              Text(message),
            ],
          ));
        });
  }

  // dismiss loading dialog
  void dismissDialog() {
    // check if there is a dialog
    if (Navigator.of(navigatorKey.currentContext!).canPop()) {
      Navigator.of(navigatorKey.currentContext!).pop();
    }
  }

  // void dismissDialog() {
  //   navigatorKey.currentState!.pop();
  // }
}
