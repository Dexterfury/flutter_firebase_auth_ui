import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth_ui/constants.dart';
import 'package:flutter_firebase_auth_ui/providers/user_auth_provider.dart';
import 'package:flutter_firebase_auth_ui/utilities/global_navigation.dart';
import 'package:flutter_firebase_auth_ui/widgets/user_image_avatar.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final userAuthProvider = context.watch<UserAuthProvider>();
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.home),
        title: const Text('Home Screen'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: GestureDetector(
                onTap: () {
                  GlobalNavigation().navigateTo(Constants.profileRoute);
                },
                child: UserImageAvatar(
                  radius: 20,
                  imageUrl: userAuthProvider.userModel?.imageUrl ?? '',
                  vieweOnly: true,
                )),
          )
        ],
      ),
      body: Center(
        child: Text(
          'Welcome ${userAuthProvider.userModel?.name ?? ''}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
