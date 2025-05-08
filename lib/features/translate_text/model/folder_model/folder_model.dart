import 'package:hive/hive.dart';
import 'package:image2text/features/translate_text/model/translation_model/translation_model.dart';
part 'folder_model.g.dart';

@HiveType(typeId: 0)
class FolderModel extends HiveObject {
  FolderModel({required this.name});
  @HiveField(0)
  String name;

  @HiveField(1)
  HiveList<TranslationModel>? translations;
}
