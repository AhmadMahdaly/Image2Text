import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

part 'recognition_text_state.dart';

class RecognitionTextCubit extends Cubit<RecognitionTextState> {
  RecognitionTextCubit() : super(RecognitionTextInitial());

  // File? imageFile;
  InputImage? inputImage;
  String extractedText = '';
  String controller = '';
  CameraController? cameraController;
  Future<void>? initializeControllerFuture;
  File? croppedImage;

  final double cropWidth = 250;
  final double cropHeight = 150;

  Future<void> initCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;
    cameraController = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    initializeControllerFuture = cameraController!.initialize();
  }

  Future<void> takePictureAndCrop(BuildContext context) async {
    emit(PickImageLoading());
    try {
      final image = await cameraController!.takePicture();
      final bytes = await File(image.path).readAsBytes();
      final decodedImage = img.decodeImage(bytes)!;
      final screenSize = MediaQuery.of(context).size;
      final scaleX = decodedImage.width / screenSize.width;
      final scaleY = decodedImage.height / screenSize.height;
      final centerX = screenSize.width / 2;
      final centerY = screenSize.height / 2;
      final cropLeft = ((centerX - cropWidth / 2) * scaleX).toInt();
      final cropTop = ((centerY - cropHeight / 2) * scaleY).toInt();
      final cropW = (cropWidth * scaleX).toInt();
      final cropH = (cropHeight * scaleY).toInt();
      final cropped = img.copyCrop(
        decodedImage,
        x: cropLeft,
        y: cropTop,
        width: cropW,
        height: cropH,
      );
      final directory = await getTemporaryDirectory();
      final croppedPath = join(directory.path, 'cropped.png');
      File(croppedPath).writeAsBytesSync(img.encodePng(cropped));
      croppedImage = File(croppedPath);
      inputImage = InputImage.fromFilePath(croppedImage!.path);
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
