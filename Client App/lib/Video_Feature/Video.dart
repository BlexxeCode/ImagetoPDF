//packages/libraries used in the video.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera_app/main.dart';

Timer? timer;

//Class that contains the section for the Video Preview. Called with button on home screen
class Video extends StatefulWidget{
  const Video({Key? key}) : super(key: key);

  @override
  State<Video> createState() => _Video();
}

class _Video extends State<Video>{

  @override
  Widget build(BuildContext context) {
    return Scaffold( // Creates a visual scaffold for material designs 
        appBar: AppBar(
          backgroundColor: Colors.green[700], //top bar with title
          title: const Text("Video Preview"),
        ),
        body: Center(
          // body that contains the decoded image on the center screen
          child: SizedBox(  //fixed sized box
            width: double.infinity,  //width adjusts the screen orientation
            height: 500,
            child: photoRefresh(),
          ),
        ),
        floatingActionButton: Wrap(
          //contains the different buttons for the scanner actions
          direction: Axis.horizontal,
          children: <Widget>[
            Container(
              //scan button
              margin:const EdgeInsets.all(10),  // spacing
              child: FloatingActionButton(
                backgroundColor: Colors.green[700],  // color of button
                onPressed: (){
                  List<int> bytes1 = 'Scan'.codeUnits;   //sends an encoded string to server
                  sock?.add(bytes1);
                },
                child: const Icon(Icons.scanner),  // icon of button
              )
            ),
            Container(
              //PDF conversion button
                margin:const EdgeInsets.all(10),
                child: FloatingActionButton(
                  backgroundColor: Colors.green[700],
                  onPressed: (){
                    List<int> bytes2 = 'PDF'.codeUnits;
                    sock?.add(bytes2);
                  },
                  child: const Icon(Icons.picture_as_pdf),
                )
            ),
            Container(
              //Mailing button
                margin:const EdgeInsets.all(10),
                child: FloatingActionButton(
                  backgroundColor: Colors.green[700],
                  onPressed: (){
                    List<int> bytes3 = 'Mail'.codeUnits;
                    sock?.add(bytes3);

                  },
                  child: const Icon(Icons.email),
                )
            ),
          ]
        ),
    );
  }
  //function the returns the decoded image 
  Image? photoRefresh(){
    while (true){
      try {
        return vid;
      }
      catch(e){
        vid = vid;
      }
    }
  }
  @override
  // this is used in order the refresh and update the image, making it seem like a video
  void initState() {
      timer = Timer.periodic(const Duration(microseconds: 33330),(_) { //update at 33.33 milliseconds 
      setState(() {});
    });
  }
  @override
  
  void dispose() {  //used to dispose of the last image when the timer 
    timer?.cancel();
  }




}


