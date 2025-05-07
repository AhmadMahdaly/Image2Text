import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

part 'recognition_text_state.dart';

class RecognitionTextCubit extends Cubit<RecognitionTextState> {
  RecognitionTextCubit() : super(RecognitionTextInitial());

  File? imageFile;
  InputImage? inputImage;
  String extractedText = '';
  String controller = '';

  Future<void> pickImage() async {
    emit(PickImageLoading());
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera,
      );

      if (pickedFile == null) {
        emit(PickImageError('No image selected'));
        return;
      }

      // Crop the image
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 2, ratioY: 3),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.white,
            toolbarWidgetColor: Colors.brown,
            lockAspectRatio: false,
          ),
        ],
      );

      if (croppedFile == null) {
        emit(PickImageError('Cropped image is null'));
        return;
      }

      imageFile = File(croppedFile.path);
      inputImage = InputImage.fromFilePath(imageFile!.path);

      await prcessImage(inputImage!);
      emit(PickImageSuccess());
    } catch (e) {
      emit(PickImageError(e.toString()));
    }
  }

  Future prcessImage(InputImage inputImage) async {
    emit(ExtractedTextLoading());
    try {
      final textRecognizer = TextRecognizer(
        script: TextRecognitionScript.latin,
      );
      final recognizedText = await textRecognizer.processImage(inputImage);

      final buffer = StringBuffer();
      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          for (final element in line.elements) {
            buffer.write('${element.text} ');
          }
        }
        buffer.write('\n\n');
      }
      extractedText = buffer.toString();
      controller = extractedText;
      emit(ExtractedTextSuccess());
    } catch (e) {
      emit(ExtractedTextError(e.toString()));
    }
  }

  Future translateWithGPT(
    String text,
    String targetLang,
    String apiKey,
    BuildContext context,
  ) async {
    emit(ExtractedTextLoading());
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Text to translate cannot be empty!')),
      );
    }
    final prompt =
        'Translate the following educational content to Arabic in a formal and academic tone. Ensure the meaning is accurate, especially for technical or scientific terms. Do not summarize or skip anything.\n\n"$text"';

    final body = jsonEncode({
      'model': 'gpt-4o-mini',
      'messages': [
        {'role': 'system', 'content': 'You are a helpful translator.'},
        {'role': 'user', 'content': prompt},
      ],
      'temperature': 0.3,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final decoded = utf8.decode(response.bodyBytes);
      final data = jsonDecode(decoded);
      final content = data['choices'][0]['message']['content'];
      emit(ExtractedTextSuccess());
      return content;
    } else {
      emit(ExtractedTextError('No text to translate'));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get translation: ${response.body}')),
      );
    }
  }
}
