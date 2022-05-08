//packages/libraries used in feedback.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:path_provider/path_provider.dart';

//stateful widget function of feedback screen
class Features extends StatefulWidget {
  const Features({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

bool _useCustomFeedback = false;

//Feedback class
class _MyAppState extends State<Features> {
  @override
  Widget build(BuildContext context) {
    return BetterFeedback(
      child: MaterialApp(
        title: 'Feedback',
        theme: ThemeData(
          primarySwatch: _useCustomFeedback ? Colors.green : Colors.blue,
        ),
      ),
      theme: FeedbackThemeData(
        background: Colors.grey,
        feedbackSheetColor: Colors.grey[50]!,
        drawColors: [
          Colors.red,
          Colors.green,
          Colors.blue,
          Colors.yellow,
        ],
      ),
      localizationsDelegates:  [
        GlobalFeedbackLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      localeOverride: const Locale('en'),
      mode: FeedbackMode.draw,
      pixelRatio: 1,
    );
  }

  //this is needed for some reason
  void _toggleCustomizedFeedback() =>
      setState(() => _useCustomFeedback = !_useCustomFeedback);
  }

//function to transfer screenshot to email from phones directory
Future<String> writeImageToStorage(Uint8List feedbackScreenshot) async {
  final Directory output = await getTemporaryDirectory();
  final String screenshotFilePath = '${output.path}/feedback.png';
  final File screenshotFile = File(screenshotFilePath);
  await screenshotFile.writeAsBytes(feedbackScreenshot);
  return screenshotFilePath;
}