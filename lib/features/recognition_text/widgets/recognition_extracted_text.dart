import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image2text/core/constans.dart';
import 'package:image2text/core/cubit/recognition_text_cubit.dart';
import 'package:image2text/core/utils/shared_widgets/custom_border_radius.dart';
import 'package:image2text/core/utils/shared_widgets/custom_button.dart';
import 'package:image2text/features/translate_text/view/translate_page.dart';

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

  bool isActive = false;
  @override
  Widget build(BuildContext context) {
    return BlocListener<TextCubit, TextState>(
      listener: (context, state) {
        if (state is PickImageSuccess || state is ExtractedTextSuccess) {
          setState(() {
            _controller.text =
                BlocProvider.of<TextCubit>(context).extractedText;
            isActive = true;
          });
        }
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _controller,
              onChanged: (extractedText) {
                setState(() {
                  BlocProvider.of<TextCubit>(context).extractedText =
                      extractedText;
                  isActive = _controller.text.isNotEmpty;
                });
              },
              maxLines: 16,
              decoration: InputDecoration(
                hintText: 'Extracted text will appear here...',
                hintStyle: const TextStyle(fontSize: 16, color: Colors.grey),
                enabledBorder: customBorderRadius(),
                focusedBorder: customBorderRadius(),
                border: customBorderRadius(),
              ),
            ),
            const SizedBox(height: 18),
            CustomButton(
              isActive: isActive,
              text: 'TRANSLATE',
              onTap: () async {
                final translate = await BlocProvider.of<TextCubit>(
                  context,
                ).translateWithGPT(_controller.text, 'Arabic', apiKey, context);
                await showModalBottomSheet<String>(
                  useSafeArea: true,
                  isDismissible: true,
                  backgroundColor: Colors.brown[50],
                  enableDrag: true,
                  useRootNavigator: true,
                  showDragHandle: true,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  context: context,
                  builder: (context) {
                    return TranslatePage(translate: translate.toString());
                  },
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
