import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:image2text/core/cubit/recognition_text_cubit.dart';
import 'package:image2text/features/translate_text/model/folder_model/folder_model.dart';
import 'package:image2text/features/translate_text/view/translation_list_screen.dart';

class SavedFoldersPage extends StatefulWidget {
  const SavedFoldersPage({super.key});

  @override
  State<SavedFoldersPage> createState() => _SavedFoldersPageState();
}

class _SavedFoldersPageState extends State<SavedFoldersPage> {
  final folderBox = Hive.box<FolderModel>('folders');
  final addController = TextEditingController();
  final renameController = TextEditingController();
  @override
  void dispose() {
    addController.dispose();
    renameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final folders = folderBox.values.toList();
    return BlocBuilder<TextCubit, TextState>(
      builder: (context, state) {
        final cubit = context.read<TextCubit>();
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 100,
            backgroundColor: Colors.brown,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_outlined,
                size: 32,
                color: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text(
              'Saved Folders',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            actions: [
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white, size: 32),
                tooltip: 'Add Folder',
                onPressed: () {
                  showDialog<String>(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text(
                            'Add Folder',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown,
                            ),
                          ),
                          content: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.grey[400] ?? Colors.grey,
                              ),
                            ),
                            child: TextField(
                              cursorWidth: 0.7,
                              controller: addController,
                              decoration: InputDecoration(
                                hintText: 'Folder Name',
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[400] ?? Colors.grey,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.brown,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () async {
                                if (addController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Folder name cannot be empty!',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                if (folders.any(
                                  (folder) =>
                                      folder.name == addController.text.trim(),
                                )) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Folder already exists!'),
                                    ),
                                  );
                                  return;
                                }
                                if (addController.text.trim().length > 20) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Folder name is too long!'),
                                    ),
                                  );
                                  return;
                                }
                                if (addController.text.trim().length < 3) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Folder name is too short!',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                await context.read<TextCubit>().addNewFolder(
                                  addController.text.trim(),
                                );
                                addController.clear();
                                Navigator.of(context).pop();
                                setState(() {});
                              },
                              child: const Text(
                                'Save',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                  );
                },
              ),
              const SizedBox(width: 10),
            ],
          ),
          body: ListView.builder(
            itemCount: folders.length,
            itemBuilder: (context, index) {
              final folder = folders[index];
              return ListTile(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: Colors.brown.withAlpha(50),
                    width: 0.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                style: ListTileStyle.list,
                trailing: PopupMenuButton<String>(
                  color: Colors.white,
                  icon: const Icon(Icons.more_vert, color: Colors.brown),
                  onSelected: (value) async {
                    if (value == 'rename') {
                      await cubit.renameFolderDialog(
                        renameController,
                        folder,
                        context,
                      );
                    } else if (value == 'delete') {
                      await cubit.deleteFolder(folder, context);
                      setState(() {});
                    }
                  },
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'rename',
                          child: Text(
                            'Rename',
                            style: TextStyle(color: Colors.brown, fontSize: 16),
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Delete',
                            style: TextStyle(color: Colors.brown, fontSize: 16),
                          ),
                        ),
                      ],
                ),
                title: Text(
                  folder.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Avenir',
                  ),
                ),
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TranslationListScreen(folder: folder),
                      ),
                    ),
              );
            },
          ),
        );
      },
    );
  }
}
