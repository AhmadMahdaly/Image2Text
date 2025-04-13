import 'package:flutter/material.dart';
import 'package:image2text/recognition_text_widget.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const RecognitionTextWidget());
  }
}
