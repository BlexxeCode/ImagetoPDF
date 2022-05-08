import 'package:camera_app/Camera_Feature/camera_feature.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'image_display_screen.dart';

//class for defining and in the design of the camera gallery
class CaptureGalleryScreen extends StatelessWidget {
  final List<File> imageFileList;

  const CaptureGalleryScreen({required this.imageFileList});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () async {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ImageCaptureScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: Colors.white,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Captures',
                      style: TextStyle(
                        fontSize: 32.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                children: [
                  for (File imageFile in imageFileList)
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => ImageDisplayScreen(
                                fileList: imageFileList,
                                imageFile: imageFile,
                              ),
                            ),
                          );
                        },
                        child: Image.file(
                          imageFile,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//Copyright (c) 2021 Souvik Biswas