import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
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
        aspectRatio: const CropAspectRatio(ratioX: 4, ratioY: 3),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crrp Image',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
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
}
