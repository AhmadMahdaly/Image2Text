import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image2text/features/recognition_text/cubit/recognition_text_cubit.dart';

class ViewUploadedImage extends StatelessWidget {
  const ViewUploadedImage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecognitionTextCubit, RecognitionTextState>(
      builder: (context, state) {
        final cubit = context.read<RecognitionTextCubit>();
        return Image.file(cubit.croppedImage!, fit: BoxFit.cover);
      },
    );
  }
}
