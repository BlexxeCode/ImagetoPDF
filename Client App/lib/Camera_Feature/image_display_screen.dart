import 'package:flutter/material.dart';
import '../Camera_Feature/camera_feature.dart';
import 'dart:io';
import '../Camera_Feature/capture_gallery_screen.dart';

//class defined for displaying a selected image from gallery
class ImageDisplayScreen extends StatelessWidget {
  final File imageFile;
  final List<File> fileList;

  const ImageDisplayScreen({
    required this.imageFile,
    required this.fileList,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => CaptureGalleryScreen(
                        imageFileList: fileList,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.photo_library_rounded),
                label: const Text('Capture Gallery'),
                style: TextButton.styleFrom(
                  primary: Colors.black,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(),
              child: ElevatedButton.icon(
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ImageCaptureScreen()),
                  );
                },
                icon: const Icon(Icons.camera_alt_rounded),
                label: const Text('Go Back to Camera'),
                style: TextButton.styleFrom(
                  primary: Colors.black,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: Image.file(imageFile),
            ),
          ],
        ),
      ),
    );
  }
}

//Copyright (c) 2021 Souvik Biswas