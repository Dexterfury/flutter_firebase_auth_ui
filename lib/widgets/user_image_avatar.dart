import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_auth_ui/utilities/assets_manager.dart';
import 'package:flutter_firebase_auth_ui/utilities/my_image_cachemanager.dart';

class UserImageAvatar extends StatelessWidget {
  const UserImageAvatar({
    super.key,
    required this.radius,
    this.fileImage,
    this.imageUrl = '',
    this.onPressed,
    this.avatarPadding = 8.0,
    this.vieweOnly = false,
  });

  final double radius;
  final File? fileImage;
  final String imageUrl;
  final VoidCallback? onPressed;
  final double avatarPadding;
  final bool vieweOnly;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            key: UniqueKey(),
            radius: radius,
            backgroundColor: Colors.grey,
            backgroundImage: showUserImage(fileImage),
          ),
          if (onPressed != null && !vieweOnly)
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: onPressed,
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  showUserImage(File? fileImage) {
    if (fileImage != null) {
      return FileImage(File(fileImage.path)) as ImageProvider<Object>;
    } else if (imageUrl.isNotEmpty) {
      return CachedNetworkImageProvider(
        imageUrl,
        cacheManager: MyImageCacheManager.profileCacheManager,
      );
    } else {
      return const AssetImage(AssetsManager.userIcon);
    }
  }
}
