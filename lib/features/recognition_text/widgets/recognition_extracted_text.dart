import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image2text/features/recognition_text/cubit/recognition_text_cubit.dart';

class RecognitionExtractedText extends StatefulWidget {
  const RecognitionExtractedText({super.key});

  @override
  State<RecognitionExtractedText> createState() =>
      _RecognitionExtractedTextState();
}

class _RecognitionExtractedTextState extends State<RecognitionExtractedText> {
  final TextEditingController _controller = TextEditingController();
  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RecognitionTextCubit, RecognitionTextState>(
      listener: (context, state) {
        if (state is PickImageSuccess || state is ExtractedTextSuccess) {
          setState(() {
            _controller.text =
                BlocProvider.of<RecognitionTextCubit>(context).extractedText;
          });
        }
      },
      child: TextField(
        controller: _controller,
        onChanged: (extractedText) {
          setState(() {
            extractedText =
                BlocProvider.of<RecognitionTextCubit>(context).extractedText;
          });
        },
        readOnly: true,
        maxLines: 7,
        decoration: InputDecoration(
          hintText: 'Extracted text will appear here...',
          hintStyle: const TextStyle(fontSize: 16, color: Colors.grey),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[400] ?? Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[400] ?? Colors.grey),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[400] ?? Colors.grey),
          ),
        ),
      ),
    );
  }
}
