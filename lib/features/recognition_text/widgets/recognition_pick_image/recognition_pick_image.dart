import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image2text/features/recognition_text/cubit/recognition_text_cubit.dart';
import 'package:image2text/features/recognition_text/widgets/recognition_pick_image/widgets/open_camera.dart';
import 'package:image2text/features/recognition_text/widgets/recognition_pick_image/widgets/upload_image_button.dart';
import 'package:image2text/features/recognition_text/widgets/recognition_pick_image/widgets/view_uplaoded_image.dart';

class RecognitionPickImage extends StatelessWidget {
  const RecognitionPickImage({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecognitionTextCubit, RecognitionTextState>(
      builder: (context, state) {
        final cubit = context.read<RecognitionTextCubit>();
        return InkWell(
          onTap: () async {
            await cubit.initCamera();
            await openCamera(context, cubit);
          },

          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[400] ?? Colors.grey),
            ),
            child:
                cubit.croppedImage != null
                    ? const ViewUploadedImage()
                    : const UploadImageButton(),
          ),
        );
      },
    );
  }
}
