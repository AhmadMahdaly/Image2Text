import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const RecognitionTextWidget());
  }
}

class RecognitionTextWidget extends StatefulWidget {
  const RecognitionTextWidget({super.key});
  @override
  State<RecognitionTextWidget> createState() => _RecognitionTextWidgetState();
}

class _RecognitionTextWidgetState extends State<RecognitionTextWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
