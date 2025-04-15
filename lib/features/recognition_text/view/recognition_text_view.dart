import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image2text/features/recognition_text/cubit/recognition_text_cubit.dart';
import 'package:image2text/features/recognition_text/widgets/recognition_extracted_text.dart';
import 'package:image2text/features/recognition_text/widgets/recognition_pick_image/recognition_pick_image.dart';
import 'package:image2text/features/recognition_text/widgets/recognition_title.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class RecognitionTextScreen extends StatefulWidget {
  const RecognitionTextScreen({super.key});
  @override
  State<RecognitionTextScreen> createState() => _RecognitionTextScreenState();
}

class _RecognitionTextScreenState extends State<RecognitionTextScreen> {
  bool _isInAsyncCall = false;
  @override
  Widget build(BuildContext context) {
    return BlocListener<RecognitionTextCubit, RecognitionTextState>(
      listener: (context, state) {
        if (state is PickImageLoading || state is ExtractedTextLoading) {
          setState(() {
            _isInAsyncCall = true;
          });
        } else if (state is PickImageSuccess || state is ExtractedTextSuccess) {
          setState(() {
            _isInAsyncCall = false;
          });
        } else {
          setState(() {
            _isInAsyncCall = false;
          });
          showDialog<String>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('No text recognition!'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Ok'),
                  ),
                ],
              );
            },
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Image2Text',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ),
        body: ModalProgressHUD(
          inAsyncCall: _isInAsyncCall,
          opacity: 1,
          blur: 1,
          color: Colors.transparent,
          progressIndicator: const Center(child: CircularProgressIndicator()),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 18,
              children: [
                RecognitionTitle(),
                SizedBox(height: 16),
                RecognitionPickImage(),
                RecognitionExtractedText(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
