import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:image2text/core/cubit/recognition_text_cubit.dart';
import 'package:image2text/features/translate_text/model/folder_model/folder_model.dart';
import 'package:image2text/features/translate_text/model/translation_model/translation_model.dart';
import 'package:image2text/features/translate_text/widgets/translation_detail_screen.dart';

class TranslationListScreen extends StatefulWidget {
  const TranslationListScreen({required this.folder, super.key});
  final FolderModel folder;

  @override
  State<TranslationListScreen> createState() => _TranslationListScreenState();
}

class _TranslationListScreenState extends State<TranslationListScreen> {
  late ScrollController _scrollController;
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // استرجاع الموضع المحفوظ
    final lastOffset = Hive.box<double>(
      'settings',
    ).get('lastScrollOffset', defaultValue: 0);
    _scrollController = ScrollController(
      initialScrollOffset: lastOffset ?? 0.0,
    );

    _scrollController.addListener(() {
      Hive.box<double>(
        'settings',
      ).put('lastScrollOffset', _scrollController.offset);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final translations = widget.folder.translations ?? [];
    return BlocBuilder<TextCubit, TextState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.brown[100],
          appBar: AppBar(
            backgroundColor: Colors.brown,
            toolbarHeight: 100,
            title: Text(
              widget.folder.name,
              style: const TextStyle(
                fontSize: 30,
                fontFamily: 'Avenir',
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_outlined,
                size: 32,
                color: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: ListView.builder(
            controller: _scrollController, // الربط هنا
            itemCount: translations.length,
            itemBuilder: (context, index) {
              final t = translations[index];
              return ListTile(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: Colors.brown.withAlpha(50),
                    width: 0.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                style: ListTileStyle.list,
                subtitle: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    t.translated.toString(),
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(fontSize: 16, fontFamily: 'Avenir'),
                  ),
                ),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => TranslationDetailScreen(
                            translation: t as TranslationModel,
                            folder: widget.folder,
                          ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
