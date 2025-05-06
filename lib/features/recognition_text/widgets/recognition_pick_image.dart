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
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.brown),
            ),
            child:
                cubit.imageFile != null
                    ? Image.file(cubit.imageFile!, fit: BoxFit.cover)
                    : const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        spacing: 12,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_rounded, color: Colors.brown),
                          Text(
                            'Upload an image to extract text.',
                            style: TextStyle(fontSize: 16, color: Colors.brown),
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
