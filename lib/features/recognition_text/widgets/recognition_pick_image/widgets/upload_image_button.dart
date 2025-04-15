import 'package:flutter/material.dart';

class UploadImageButton extends StatelessWidget {
  const UploadImageButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        spacing: 12,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_rounded, color: Colors.grey[500] ?? Colors.grey),
          const Text(
            'Upload an image to extract text.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
