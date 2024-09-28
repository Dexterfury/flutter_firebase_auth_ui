import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_apple/firebase_ui_oauth_apple.dart';
import 'package:firebase_ui_oauth_facebook/firebase_ui_oauth_facebook.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FirebaseAuthConfig {
  static void configureProvider() {
    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
      PhoneAuthProvider(),
      GoogleProvider(
        clientId: getGoogleClientId,
        iOSPreferPlist: true,
      ),
      AppleProvider(),
      FacebookProvider(
        clientId: getFacebookClientId,
      ),
    ]);
  }

  // get the google client id from .env file
  static String get getGoogleClientId {
    return dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';
  }

  // get facebook client id from .env file
  static String get getFacebookClientId {
    return dotenv.env['FACEBOOK_APP_ID'] ?? '';
  }
}
