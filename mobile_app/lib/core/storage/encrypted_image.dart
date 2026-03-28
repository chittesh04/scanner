import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartscan/core/di/service_locator.dart';
import 'package:shimmer/shimmer.dart';

class EncryptedImage extends ConsumerWidget {
  const EncryptedImage({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  final String imagePath;
  final BoxFit fit;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.watch(fileStorageProvider);

    return FutureBuilder<Uint8List>(
      future: storage.readEncrypted(File(imagePath)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Shimmer.fromColors(
            baseColor: Colors.black12,
            highlightColor: Colors.white54,
            child: Container(
              width: width,
              height: height,
              color: Colors.white,
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Icon(Icons.broken_image, size: 48));
        }

        return Image.memory(
          snapshot.data!,
          fit: fit,
          width: width,
          height: height,
        );
      },
    );
  }
}
