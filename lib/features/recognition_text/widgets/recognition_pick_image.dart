import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image2text/features/recognition_text/cubit/recognition_text_cubit.dart';

class RecognitionPickImage extends StatelessWidget {
  const RecognitionPickImage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecognitionTextCubit, RecognitionTextState>(
      builder: (context, state) {
        final cubit = context.read<RecognitionTextCubit>();
        return InkWell(
          onTap: cubit.pickImage,
          child: Container(
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.brown,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                spacing: 12,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_rounded, color: Colors.white),
                  Text(
                    'Upload an image to extract text.',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
