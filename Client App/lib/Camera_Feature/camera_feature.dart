import 'dart:io';
import 'package:feedback/feedback.dart';
import 'package:camera/camera.dart';
import 'package:camera_app/HomePage/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:camera_app/HomePage/home.dart';
import 'image_display_screen.dart';
import 'package:camera_app/main.dart';

//main class for the camera screen
class ImageCaptureScreen extends StatefulWidget {
  const ImageCaptureScreen({Key? key}) : super(key: key);

  @override
  _ImageCaptureScreenState createState() => _ImageCaptureScreenState();
}

//this class encompasses the rest of the code, includes all the features
class _ImageCaptureScreenState extends State<ImageCaptureScreen>
    with WidgetsBindingObserver {
  CameraController? controller; //controller for the camera

  bool _isCameraInitialized = false;

  final resolutionPresets = ResolutionPreset.values;
  ResolutionPreset currentResolutionPreset = ResolutionPreset.max;

  //initial values for zoom
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentZoomLevel = 1.0;

  FlashMode? _currentFlashMode;

  File? _imageFile;

  List<File> allFileList = [];

  //function for updating or refreshing to latest image saved
  refreshAlreadyCapturedImages() async {
    // Get the directory
    final directory = await getExternalStorageDirectory();
    List<FileSystemEntity> fileList = await directory!.list().toList();
    allFileList.clear();

    List<Map<int, dynamic>> fileNames = [];

    // Searching for all the image and video files using
    // their default format, and storing them
    fileList.forEach((file) {
      if (file.path.contains('.jpg')) {
        allFileList.add(File(file.path));

        String name = file.path.split('/').last.split('.').first;
        fileNames.add({0: int.parse(name), 1: file.path.split('/').last});
      }
    });

    // Retrieving the recent file
    if (fileNames.isNotEmpty) {
      final recentFile =
          fileNames.reduce((curr, next) => curr[0] > next[0] ? curr : next);
      String recentFileName = recentFile[1];
      // Checking whether it is an image or a video file
      if (recentFileName.contains('.jpg')) {
        _imageFile = File('${directory.path}/$recentFileName');
      }

      setState(() {});
    }
  }

  //function for taking a picture along with functionality for storing images
  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;
    if (cameraController!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }
    try {
      XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      print('Error occurred while taking picture: $e');
      return null;
    }
  }

  void resetCameraValues() async {
    _currentZoomLevel = 1.0;
  }

  //function for initializing new camera controller and disposing previous one
  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = controller;
    // Instantiating the camera controller
    final CameraController cameraController = CameraController(
      cameraDescription,
      currentResolutionPreset,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    // Dispose the previous controller
    await previousCameraController?.dispose();

    resetCameraValues();

    // Replace with the new controller
    if (mounted) {
      setState(() {
        controller = cameraController;
      });
    }

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    // Initialize controller
    try {
      await cameraController.initialize();
      await Future.wait([
        cameraController
            .getMaxZoomLevel()
            .then((value) => _maxAvailableZoom = value),
        cameraController
            .getMinZoomLevel()
            .then((value) => _minAvailableZoom = value),
      ]);

      _currentFlashMode = controller!.value.flashMode;
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
    }

    // Update the Boolean
    if (mounted) {
      setState(() {
        _isCameraInitialized = controller!.value.isInitialized;
      });
    }
  }

  @override
  void initState() {
    // Hide the status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    onNewCameraSelected(cameras[0]);
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  //managing lifecycle changes
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      // Free up memory when camera not active
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize the camera with same properties
      onNewCameraSelected(cameraController.description);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.black,
          body: _isCameraInitialized
              ? Column(
                  children: [
                    AspectRatio(
                      aspectRatio: 1 / controller!.value.aspectRatio,
                      child: Stack(
                        children: [
                          controller!.buildPreview(),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              16.0,
                              8.0,
                              16.0,
                              8.0,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black87,
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 8.0,
                                        right: 8.0,
                                      ),
                                      child: DropdownButton<ResolutionPreset>(
                                        dropdownColor: Colors.black87,
                                        underline: Container(),
                                        value: currentResolutionPreset,
                                        items: [
                                          for (ResolutionPreset preset
                                              in resolutionPresets)
                                            DropdownMenuItem(
                                              child: Text(
                                                preset
                                                    .toString()
                                                    .split('.')[1]
                                                    .toUpperCase(),
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                              value: preset,
                                            )
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            currentResolutionPreset = value!;
                                            _isCameraInitialized = false;
                                          });
                                          onNewCameraSelected(
                                              controller!.description);
                                        },
                                        hint: const Text("Select item"),
                                      ),
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Row(
                                  //crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: Slider(
                                        value: _currentZoomLevel,
                                        min: _minAvailableZoom,
                                        max: _maxAvailableZoom,
                                        activeColor: Colors.white,
                                        inactiveColor: Colors.white30,
                                        onChanged: (value) async {
                                          setState(() {
                                            _currentZoomLevel = value;
                                          });
                                          await controller!.setZoomLevel(value);
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black87,
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            _currentZoomLevel
                                                    .toStringAsFixed(1) +
                                                'x',
                                            style:
                                                const TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  // crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Align(
                                      alignment: Alignment.topLeft,
                                      //child: Padding(
                                      // padding: const EdgeInsets.fromLTRB(
                                      //   16.0,
                                      //   450.0,
                                      //   16.0,
                                      //   8.0,
                                      // ),
                                      child: IconButton(
                                        onPressed: () async {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => const BetterFeedback(child: Homepage()),
                                            )
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.cancel_rounded,
                                          size: 35.0,
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        XFile? rawImage = await takePicture();
                                        File imageFile = File(rawImage!.path);

                                        int currentUnix = DateTime.now()
                                            .millisecondsSinceEpoch;

                                        final directory =
                                            await getExternalStorageDirectory();

                                        String fileFormat =
                                            imageFile.path.split('.').last;

                                        print(fileFormat);

                                        await imageFile.copy(
                                          '${directory?.path}/$currentUnix.$fileFormat',
                                        );

                                        refreshAlreadyCapturedImages();
                                      },
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Icon(Icons.circle,
                                              color: Colors.amber[300],
                                              size: 80),
                                          const Icon(Icons.circle,
                                              color: Colors.white, size: 70),
                                        ],
                                      ),
                                    ),
                                    InkWell(
                                      onTap: _imageFile != null
                                          ? () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ImageDisplayScreen(
                                                    imageFile: _imageFile!,
                                                    fileList: allFileList,
                                                  ),
                                                ),
                                              );
                                            }
                                          : null,
                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                          image: _imageFile != null
                                              ? DecorationImage(
                                                  image: FileImage(_imageFile!),
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  16.0, 8.0, 16.0, 8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      setState(() {
                                        _currentFlashMode = FlashMode.off;
                                      });
                                      await controller!.setFlashMode(
                                        FlashMode.off,
                                      );
                                    },
                                    child: Icon(
                                      Icons.flash_off_rounded,
                                      color: _currentFlashMode == FlashMode.off
                                          ? Colors.amber
                                          : Colors.white,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      setState(() {
                                        _currentFlashMode = FlashMode.auto;
                                      });
                                      await controller!.setFlashMode(
                                        FlashMode.auto,
                                      );
                                    },
                                    child: Icon(
                                      Icons.flash_auto_rounded,
                                      color: _currentFlashMode == FlashMode.auto
                                          ? Colors.amber
                                          : Colors.white,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      setState(() {
                                        _currentFlashMode = FlashMode.always;
                                      });
                                      await controller!.setFlashMode(
                                        FlashMode.always,
                                      );
                                    },
                                    child: Icon(
                                      Icons.flash_on_rounded,
                                      color:
                                          _currentFlashMode == FlashMode.always
                                              ? Colors.amber
                                              : Colors.white,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      setState(() {
                                        _currentFlashMode = FlashMode.torch;
                                      });
                                      await controller!.setFlashMode(
                                        FlashMode.torch,
                                      );
                                    },
                                    child: Icon(
                                      Icons.highlight,
                                      color:
                                          _currentFlashMode == FlashMode.torch
                                              ? Colors.amber
                                              : Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Container()),
    );
  }
}




//Copyright (c) 2021 Souvik Biswas

//Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.