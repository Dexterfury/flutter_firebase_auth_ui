import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_firebase_auth_ui/api/firebase_auth_config.dart';
import 'package:flutter_firebase_auth_ui/constants.dart';
import 'package:flutter_firebase_auth_ui/firebase_options.dart';
import 'package:flutter_firebase_auth_ui/providers/user_auth_provider.dart';
import 'package:flutter_firebase_auth_ui/screens/home_screen.dart';
import 'package:flutter_firebase_auth_ui/screens/landing_screen.dart';
import 'package:flutter_firebase_auth_ui/utilities/auth_screens.dart';
import 'package:flutter_firebase_auth_ui/utilities/global_navigation.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // initianlize environment variables file
  await dotenv.load(fileName: ".env");

  // configure providers
  FirebaseAuthConfig.configureProvider();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => UserAuthProvider()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      navigatorKey: GlobalNavigation().navigatorKey,
      initialRoute: Constants.landingRoute,
      routes: _buildAppRoutes(),
    );
  }

  Map<String, WidgetBuilder> _buildAppRoutes() {
    return {
      Constants.landingRoute: (context) => const LandingScreen(),
      Constants.signInRoute: (context) =>
          AuthScreens.buildSignInScreen(context),
      Constants.profileRoute: (context) =>
          AuthScreens.buildProfileScreen(context),
      Constants.homeRoute: (context) => const HomeScreen(),
      Constants.verifyEmailRoute: (context) =>
          AuthScreens.buildEmailVerificationScreen(context),
      Constants.phoneVerificationRoute: (context) =>
          AuthScreens.buildPhoneInputScreen(context),
      Constants.smsVerificationRoute: (context) =>
          AuthScreens.buildSMSVerificationScreen(context),
    };
  }
}
