import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image2text/core/cubit/recognition_text_cubit.dart';
import 'package:image2text/features/translate_text/model/folder_model/folder_model.dart';
import 'package:image2text/features/translate_text/model/translation_model/translation_model.dart';

class TranslationDetailScreen extends StatefulWidget {
  const TranslationDetailScreen({
    required this.translation,
    required this.folder,
    super.key,
  });
  final TranslationModel translation;
  final FolderModel folder;

  @override
  State<TranslationDetailScreen> createState() =>
      _TranslationDetailScreenState();
}

class _TranslationDetailScreenState extends State<TranslationDetailScreen> {
  TextEditingController controller = TextEditingController();
  @override
  void initState() {
    controller = TextEditingController(text: widget.translation.title ?? '');
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.translation;
    return BlocBuilder<TextCubit, TextState>(
      builder: (context, state) {
        final cubit = context.read<TextCubit>();
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              t.title ?? 'No Title',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Avenir',
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_outlined),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'rename') {
                    await cubit.renameTitle(controller, t, context);
                  } else if (value == 'delete') {
                    await cubit.deleteTranslation(t, widget.folder, context);
                    setState(() {});
                  } else if (value == 'copy') {
                    await Clipboard.setData(ClipboardData(text: t.translated));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Text copied to clipboard!'),
                      ),
                    );
                  }
                },
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(
                        value: 'rename',
                        child: Row(
                          spacing: 6,
                          children: [Icon(Icons.edit), Text('Rename')],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          spacing: 6,
                          children: [Icon(Icons.delete), Text('Delete')],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'copy',
                        child: Row(
                          spacing: 6,
                          children: [Icon(Icons.copy), Text('Copy')],
                        ),
                      ),
                    ],
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Original text:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(t.source, style: const TextStyle(fontSize: 16)),

                  const SizedBox(height: 24),
                  const Text(
                    'Translate:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  const SizedBox(height: 8),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      t.translated,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Avenir',
                      ),
                    ),
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
