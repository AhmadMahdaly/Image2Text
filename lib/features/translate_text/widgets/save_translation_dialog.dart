import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image2text/core/cubit/recognition_text_cubit.dart';
import 'package:image2text/core/utils/shared_widgets/custom_border_radius.dart';
import 'package:image2text/features/translate_text/model/folder_model/folder_model.dart';

class SaveTranslationDialog extends StatefulWidget {
  const SaveTranslationDialog({required this.translated, super.key});
  final String translated;
  @override
  State<SaveTranslationDialog> createState() => _SaveTranslationDialogState();
}

class _SaveTranslationDialogState extends State<SaveTranslationDialog> {
  final TextEditingController newFolderController = TextEditingController();
  @override
  void dispose() {
    newFolderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TextCubit, TextState>(
      builder: (context, state) {
        final cubit = context.read<TextCubit>();
        return AlertDialog(
          title: const Text('Save Translation'),
          content: ValueListenableBuilder(
            valueListenable: Hive.box<FolderModel>('folders').listenable(),
            builder: (context, Box<FolderModel> box, _) {
              final folders = box.values.toList();
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<FolderModel>(
                  borderRadius: BorderRadius.circular(8),
                  underline: const SizedBox(),
                  value: cubit.selectedFolder,
                  isExpanded: true,
                  hint: const Text('Choose a folder'),
                  items: [
                    ...folders.map((folder) {
                      return DropdownMenuItem<FolderModel>(
                        value: folder,
                        child: Text(folder.name),
                      );
                    }),
                    const DropdownMenuItem<FolderModel>(
                      value: null,
                      child: Text(
                        '+ Add New Folder',
                        style: TextStyle(
                          color: Colors.brown,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  onChanged: (folder) {
                    if (folder == null) {
                      showDialog<String>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text(
                              'New Folder',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.brown,
                              ),
                            ),
                            content: TextField(
                              controller: newFolderController,
                              decoration: InputDecoration(
                                border: customBorderRadius(),
                                focusedBorder: customBorderRadius(),
                                enabledBorder: customBorderRadius(),
                                hintText: 'Enter folder name',
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.brown),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  final name = newFolderController.text.trim();
                                  if (name.isNotEmpty) {
                                    cubit.addNewFolder(name);
                                    Navigator.pop(context);
                                  }
                                },
                                child: const Text(
                                  'Add',
                                  style: TextStyle(
                                    color: Colors.brown,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      cubit.selectFolder(folder);
                    }
                  },
                ),
              );
            },
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.brown),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
              onPressed: () async {
                if (cubit.selectedFolder == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a folder')),
                  );
                  return;
                }
                await cubit.saveTranslation(widget.translated, context);
              },

              child: Text(
                'Save',
                style: TextStyle(
                  color:
                      cubit.selectedFolder == null ? Colors.grey : Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
