class Constants {
  // route names
  static const String homeRoute = '/';
  static const String signInRoute = '/sign-in';
  static const String verifyEmailRoute = '/verify-email';
  static const String forgotPasswordRoute = '/forgot-password';
  static const String profileRoute = '/profile';
  static const String landingRoute = '/landing';
  static const String phoneVerificationRoute = '/phone-verification';
  static const String smsVerificationRoute = '/sms';

  // firestore collections
  static const String usersCollection = 'users';

  // firestore storage buckets
  static const String profileImagesBucket = 'profileImages';

  // cachmanager keys
  static const String userImageCacheKey = 'userImage';

  // userModel constants
  static const String uid = 'uid';
  static const String name = 'name';
  static const String imageUrl = 'imageUrl';
  static const String email = 'email';
  static const String phone = 'phone';
  static const String aboutMe = 'aboutMe';
  static const String createdAt = 'createdAt';
  static const String fcmToken = 'fcmToken';
  static const String isOnline = 'inOnline';
}
