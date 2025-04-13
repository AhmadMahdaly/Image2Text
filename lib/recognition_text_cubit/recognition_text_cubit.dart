import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';

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
        source: ImageSource.gallery,
      );

      imageFile = File(pickedFile!.path);
      inputImage = InputImage.fromFilePath(pickedFile.path);

      // Call this method to extract text from the image
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
