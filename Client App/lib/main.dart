//packages/libraries used in the main.dart
import 'package:camera/camera.dart';
import 'package:feedback/feedback.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'HomePage/home.dart';
import 'dart:io';
import 'dart:typed_data';

//variable to grab any cameras on the phone and input into a list
List<CameraDescription> cameras = [];
//variable for vid
Image? vid;
//integer variable
int? f;
//socket variable
Socket? sock;

//main function to run the app and initialize stuff
void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error in retrieving available cameras: $e');
  }
  runApp(const MyApp());
}

//Beginning start of the App function leading to others
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BetterFeedback(child: Homepage()), //initalizees the hompage in home.dart along with feedback function
    );
  }
  
}

//function where has the socket programming
Future <void> deviceConnect(String ipaddress) async {
  // connect to the socket server
  Socket socket;

  socket = await Socket.connect(ipaddress, 10050);
  sock = socket;
  //print('Connected to: ${socket.remoteAddress.address}:${socket.remotePort}');
  socket.listen(
    // handle data from the server
        (Uint8List data) async {
      try {
        f = data.length;
        Uint8List? serverResponse =  Uint8List.fromList(data);
        vid =  Image.memory(serverResponse,
            repeat: ImageRepeat.repeat,
            gaplessPlayback: true,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace){
              return Container(
                alignment: Alignment.center,
                color: Colors.black,
              );
            }
        );
        serverResponse = null;


      }
      on FormatException{
        print('ignore');
      }

      print('Server: $f');
    },
    // handle errors
    onError: (error) {
      print(error);
      socket.destroy();
    },

    // handle server ending connection
    onDone: () {
      print('Server left.');
      socket.destroy();
    },
  );
}
