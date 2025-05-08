import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image2text/features/translate_text/widgets/save_translation_dialog.dart';

class TranslatePage extends StatelessWidget {
  const TranslatePage({required this.translate, super.key});
  final String translate;
  @override
  Widget build(BuildContext context) {
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
                    showDialog<String>(
                      context: context,
                      builder:
                          (context) =>
                              SaveTranslationDialog(translated: translate),
                    );
                  },
                  icon: const Icon(Icons.save),
                ),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: translate));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Text copied to clipboard!'),
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
                    fontFamily: 'Avenir',
                  ),
                ),
                const SizedBox(width: 36),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            SizedBox(
              child: Text(
                translate,
                textDirection: TextDirection.rtl,
                style: const TextStyle(fontSize: 16, fontFamily: 'Avenir'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
