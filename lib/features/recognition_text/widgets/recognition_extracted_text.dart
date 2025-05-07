import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image2text/core/constans.dart';
import 'package:image2text/features/recognition_text/cubit/recognition_text_cubit.dart';
import 'package:image2text/features/recognition_text/widgets/custom_button.dart';

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
    return BlocListener<RecognitionTextCubit, RecognitionTextState>(
      listener: (context, state) {
        if (state is PickImageSuccess || state is ExtractedTextSuccess) {
          setState(() {
            _controller.text =
                BlocProvider.of<RecognitionTextCubit>(context).extractedText;
            isActive = true;
          });
        }
      },
      child: Column(
        children: [
          TextField(
            controller: _controller,
            onChanged: (extractedText) {
              setState(() {
                extractedText =
                    BlocProvider.of<RecognitionTextCubit>(
                      context,
                    ).extractedText;
              });
            },

            maxLines: 16,
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
          const Spacer(),

          CustomButton(
            isActive: isActive,
            text: 'TRANSLATE',
            onTap: () async {
              final translate = await BlocProvider.of<RecognitionTextCubit>(
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
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                context: context,
                builder: (context) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(text: translate.toString()),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Text copied to clipboard!',
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.copy),
                              ),

                              const Text(
                                'Translated Text',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            child: Text(
                              translate.toString(),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
