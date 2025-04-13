import 'package:flutter/material.dart';

class RecognitionTitle extends StatelessWidget {
  const RecognitionTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Upload an image to extract text.',
      style: TextStyle(fontSize: 16, color: Colors.grey),
    );
  }
}
