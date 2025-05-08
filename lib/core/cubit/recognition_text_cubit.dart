import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:image2text/core/constans.dart';
import 'package:image2text/core/utils/shared_widgets/custom_border_radius.dart';
import 'package:image2text/features/translate_text/model/folder_model/folder_model.dart';
import 'package:image2text/features/translate_text/model/translation_model/translation_model.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

part 'recognition_text_state.dart';

class TextCubit extends Cubit<TextState> {
  TextCubit() : super(TextInitial());

  File? imageFile;
  InputImage? inputImage;
  String extractedText = '';
  String controller = '';
  FolderModel? selectedFolder;

  ///
  Future<void> pickImage() async {
    emit(PickImageLoading());
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera,
      );

      if (pickedFile == null) {
        emit(PickImageError('No image selected'));
        return;
      }

      // Crop the image
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 2, ratioY: 3),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.white,
            toolbarWidgetColor: Colors.brown,
            lockAspectRatio: false,
          ),
        ],
      );

      if (croppedFile == null) {
        emit(PickImageError('Cropped image is null'));
        return;
      }

      imageFile = File(croppedFile.path);
      inputImage = InputImage.fromFilePath(imageFile!.path);

      await prcessImage(inputImage!);
      emit(PickImageSuccess());
    } catch (e) {
      emit(PickImageError(e.toString()));
    }
  }

  ///
  Future prcessImage(InputImage inputImage) async {
    emit(ExtractedTextLoading());
    try {
      final textRecognizer = TextRecognizer(
        script: TextRecognitionScript.latin,
      );
      final recognizedText = await textRecognizer.processImage(inputImage);

      final buffer = StringBuffer();
      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          for (final element in line.elements) {
            buffer.write('${element.text} ');
          }
        }
        buffer.write('\n\n');
      }
      extractedText = buffer.toString();
      controller = extractedText;
      emit(ExtractedTextSuccess());
    } catch (e) {
      emit(ExtractedTextError(e.toString()));
    }
  }

  ///
  Future translateWithGPT(
    String text,
    String targetLang,
    String apiKey,
    BuildContext context,
  ) async {
    emit(ExtractedTextLoading());
    final url = Uri.parse(baseUrl);

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Text to translate cannot be empty!')),
      );
    }
    final prompt =
        'ترجم النص التالي إلى العربية ترجمة أدبية غير حرفية، بحيث تكون مفهومة وسلسة للقارئ العربي، وتعكس المعنى والسياق الأصلي بأسلوب واضح وجذاب. إذا كان النص المرسل غير مكتمل أو يتوقف عند نهاية غير نهائية، فاختم الترجمة بجملة تمهيدية تربط نهاية النص بما سيليه، دون اختلاق أحداث غير موجودة.. والتزم فقط بالنص دون اي حديث غيره.\n\n"$text"';
    // 'Translate the following text from English to Arabic. Keep the meaning accurate and use natural $targetLang: \n\n"$text"';
    // 'Translate the following casual conversation into natural spoken $targetLang: \n\n"$text"';
    // 'Translate the following educational content to Arabic in a formal and academic tone. Ensure the meaning is accurate, especially for technical or scientific terms. Do not summarize or skip anything.\n\n"$text"';

    final body = jsonEncode({
      'model': 'gpt-4o-mini',
      'messages': [
        {
          'role': 'system',
          'content':
              'You are a professional literary translator. You translate texts into smooth, natural Arabic that preserves the meaning and style, avoids literal translation, and ensures coherence. If the input is a partial or incomplete passage, end the translation with a sentence that hints at continuation without inventing details.',
        },
        {
          'role': 'user',
          'content': prompt, // محتوى الصفحة من الكتاب
        },
      ],
      'temperature': 0.3,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final decoded = utf8.decode(response.bodyBytes);
      final data = jsonDecode(decoded);
      final content = data['choices'][0]['message']['content'];
      emit(ExtractedTextSuccess());
      return content;
    } else {
      emit(ExtractedTextError('No text to translate'));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get translation: ${response.body}')),
      );
    }
  }

  ///
  Future<void> saveTranslation(String translated, BuildContext context) async {
    emit(SaveTranslationLoading());

    final translationBox = Hive.box<TranslationModel>('translations');
    final translation = TranslationModel(
      source: extractedText,
      translated: translated,
      title: translated.length > 8 ? translated.substring(0, 8) : translated,
      createdAt: DateTime.now(),
    );

    final key = await translationBox.add(translation);
    final savedTranslation = translationBox.get(key)!;

    selectedFolder!.translations ??= HiveList(translationBox);
    selectedFolder!.translations!.add(savedTranslation);
    await selectedFolder!.save();
    emit(SaveTranslationSuccess());
    Navigator.of(context).pop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Saved successfully!')));
  }

  ///
  Future<void> renameTitle(
    TextEditingController controller,
    TranslationModel translation,
    BuildContext context,
  ) async {
    emit(RenameTitleLoading());
    if (translation.title == null || translation.title!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Title cannot be empty!')));
      emit(RenameTitleError());
      return;
    }

    await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'Edit Title',
              style: TextStyle(
                color: Colors.brown,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                border: customBorderRadius(),
                focusedBorder: customBorderRadius(),
                enabledBorder: customBorderRadius(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.brown),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  translation.title = controller.text.trim();
                  await translation.save();
                  emit(RenameTitleSuccess());
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
                child: const Text(
                  'Save',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> deleteTranslation(
    TranslationModel translation,
    FolderModel folder,
    BuildContext context,
  ) async {
    emit(DeleteTranslationLoading());
    try {
      final confirm = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text(
                'Confirm Delete',
                style: TextStyle(
                  color: Colors.brown,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: const Text(
                'Are you sure you want to delete this translation?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.brown),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'Save',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
      );

      if (confirm == true) {
        folder.translations?.remove(translation);
        await folder.save();
        await translation.delete();
      }
      Navigator.of(context).pop(); // رجوع بعد الحذف
      emit(DeleteTranslationSuccess());
    } catch (e) {
      emit(DeleteTranslationError(e.toString()));
    }
  }

  ///
  Future<void> addNewFolder(String name) async {
    emit(AddNewFolderLoading());
    if (name.isEmpty) {
      emit(AddNewFolderError('Folder name cannot be empty'));
      return;
    }
    final foldersBox = Hive.box<FolderModel>('folders');
    final newFolder = FolderModel(name: name);
    final key = await foldersBox.add(newFolder);
    selectedFolder = foldersBox.get(key);
    emit(AddNewFolderSuccess());
  }

  ///
  void selectFolder(FolderModel folder) {
    selectedFolder = folder;
    emit(SelectedFolderChanged());
  }

  ///
  Future<void> renameFolderDialog(
    TextEditingController controller,
    FolderModel folder,
    BuildContext context,
  ) async {
    controller.text = folder.name;

    await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename Folder'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'New Folder Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name cannot be empty!')),
                  );
                  return;
                }
                if (newName.length < 2 || newName.length > 20) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Name must be 3-20 characters!'),
                    ),
                  );
                  return;
                }
                if (Hive.box<FolderModel>(
                  'folders',
                ).values.any((f) => f.name == newName && f.key != folder.key)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name already exists!')),
                  );
                  return;
                }

                folder.name = newName;
                await folder.save();
                emit(RenameFolderSuccess());
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  ///
  Future<void> deleteFolder(FolderModel folder, BuildContext context) async {
    emit(DeleteFolderLoading());
    if (folder.translations != null) {
      for (final translation in folder.translations!) {
        await translation.delete();
      }
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text('Are you sure you want to delete this folder?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Save'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await folder.delete();
      emit(DeleteFolderSuccess());
    }
  }
}
