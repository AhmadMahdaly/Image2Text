import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image2text/core/cubit/recognition_text_cubit.dart';
import 'package:image2text/features/history_page/view/folders_page.dart';
import 'package:image2text/features/recognition_text/widgets/recognition_extracted_text.dart';
import 'package:image2text/features/recognition_text/widgets/recognition_pick_image.dart';
import 'package:image2text/features/recognition_text/widgets/recognition_title.dart';
import 'package:image2text/features/recognition_text/widgets/show_dialog_with_back_botton.dart';
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
    return BlocListener<TextCubit, TextState>(
      listener: (context, state) {
        if (state is PickImageLoading || state is ExtractedTextLoading) {
          setState(() {
            _isInAsyncCall = true;
          });
        } else if (state is PickImageSuccess || state is ExtractedTextSuccess) {
          setState(() {
            _isInAsyncCall = false;
          });
        } else if (state is PickImageError || state is ExtractedTextError) {
          setState(() {
            _isInAsyncCall = false;
            showDialogWithBackButton(context, 'No text recognition!');
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Image2Text',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FoldersPage()),
                );
              },
              icon: const Icon(
                Icons.folder_outlined,
                color: Colors.brown,
                size: 32,
              ),
            ),
            const SizedBox(width: 10),
          ],
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
                RecognitionPickImage(),
                Expanded(child: RecognitionExtractedText()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
