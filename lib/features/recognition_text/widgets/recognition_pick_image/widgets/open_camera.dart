import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image2text/features/recognition_text/cubit/recognition_text_cubit.dart';

Future<String?> openCamera(BuildContext context, RecognitionTextCubit cubit) {
  return showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Text recognition!'),
        actions: [
          SizedBox(
            height: 400,
            child:
                cubit.cameraController == null
                    ? const Center(child: CircularProgressIndicator())
                    : Stack(
                      fit: StackFit.expand,
                      children: [
                        FutureBuilder<void>(
                          future: cubit.initializeControllerFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              return CameraPreview(cubit.cameraController!);
                            } else {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          },
                        ),
                        Center(
                          child: Container(
                            width: cubit.cropWidth,
                            height: cubit.cropHeight,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.red, width: 2),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            await cubit.takePictureAndCrop(context);
                            Navigator.pop(context);
                            // await cubit.cameraController!.dispose();
                          },
                          icon: const Icon(Icons.camera),
                        ),
                      ],
                    ),
          ),
        ],
      );
    },
  );
}
