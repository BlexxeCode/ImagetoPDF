//packages/libraries used in the home.dart
import 'package:camera_app/Feedback_Feature/feedback.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:feedback/feedback.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import '../Background/widgets.dart';
import '../Camera_Feature/camera_feature.dart';
import 'package:camera_app/main.dart';
import 'package:camera_app/Video_Feature/Video.dart';
import 'package:shared_preferences/shared_preferences.dart';

//Beginning of the HomePage Function STATEFUL
class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

//HomePage Class
class _HomepageState extends State<Homepage> {

  final _ip = TextEditingController();
  String ipAddr = ' ';

  @override
  //initialize the state of the screen
  void initState(){
    getData();
  }
  //get the locally saved data where the ip is stored in a string
  getData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      ipAddr = prefs.getString('ipAddr')!;
      deviceConnect(ipAddr);
    });
  }

  //displays the text in the homepage screen
  display() {
    if(ipAddr != null) {
      return Text("Set IP-Address is $ipAddr", style: TextStyle(color: Colors.black, fontSize: 15,),);
    }
    else {
      return Text("Set IP-Address!",style: TextStyle(color: Colors.black, fontSize: 15,),);
    }
  }

  //HomePage initialized Widgets
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
          children: [
            const BackgroundImage(),
            Scaffold(
              //background function
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: const Text('Home Page'),// tile on the top page
                centerTitle: true,
                automaticallyImplyLeading: false,
                backgroundColor: Colors.teal[800],
                foregroundColor: Colors.white,

              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //button to change screen to video preview
                        ElevatedButton.icon(
                            icon: const Icon(Icons.videocam),
                            label: const Text('Scanner Preview'),
                            style: ElevatedButton.styleFrom(primary: Colors.green[700], onPrimary: Colors.white),
                            onPressed: ()  async {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const Video())
                              );
                            }
                        ),
                        //button to change screen to camera scanner that was for testing purposes where we planned to combine with video preview
                        ElevatedButton.icon(
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Camera Scanner'),
                          style: ElevatedButton.styleFrom(primary: Colors.green[700], onPrimary: Colors.white),
                          onPressed: ()  async {
                            // final cameras = await availableCameras();
                            // final firstCamera = cameras.first;
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>  const ImageCaptureScreen()),
                            );
                          },
                        ),
                        //Text Button for feedback for the user to write and send
                        if(!kIsWeb && (Platform.isAndroid || Platform.isIOS)) ...[
                          TextButton.icon(
                            label: const Text('E-Mail Feedback'),
                            icon: const Icon(Icons.feedback),
                            style: TextButton.styleFrom(primary: Colors.green[500]),
                            onPressed: () {
                              BetterFeedback.of(context).show((feedback) async {
                                // draft an email and send to developer
                                final screenshotFilePath =
                                await writeImageToStorage(feedback.screenshot);
                                final Email email = Email(
                                  body: feedback.text,
                                  subject: 'App Feedback',
                                  recipients: ['@gmail.com'],
                                  attachmentPaths: [screenshotFilePath],
                                  isHTML: false,
                                );
                                await FlutterEmailSender.send(email);
                              }
                              );
                            },
                          ),
                          const Text('  '),
                          const Text('Change IP-Address to connect to device'),
                          Padding(
                            padding: EdgeInsets.only(top: 15, bottom: 15),
                            child: display(),
                          ),
                          const Text('  '),
                          //insert texting box to write ip and saves it in a string locally on the app
                          TextField(
                            controller: _ip,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'IP-Address',
                              hintText: '123.456.7.89',
                              prefixIcon: Icon(Icons.cast_connected),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.close),
                                onPressed: () => _ip.clear(),
                              ),
                            ),
                          ),
                          //button to save ip address and reconnect to the microcontroller
                          ElevatedButton(
                            child: Text('Save/Reconnect'),
                            style: ElevatedButton.styleFrom(primary: Colors.green[700], onPrimary: Colors.white),
                            onPressed: () async {
                              if (_ip != null) {
                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                setState(() {
                                  ipAddr = _ip.text;
                                  //deviceConnect(ipAddr);
                                });
                                //sets the new string data that was new;y inputted form the text box
                                prefs.setString('ipAddr', _ip.text);
                                deviceConnect(ipAddr);
                              }
                            },
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ]
      ),
    );
  }
}





