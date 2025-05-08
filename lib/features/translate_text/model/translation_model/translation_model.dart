import 'package:hive/hive.dart';
part 'translation_model.g.dart';

@HiveType(typeId: 1)
class TranslationModel extends HiveObject {
  TranslationModel({
    required this.source,
    required this.translated,
    required this.createdAt,
    this.title,
  });
  @HiveField(0)
  String source;

  @HiveField(1)
  String translated;

  @HiveField(2)
  String? title;

  @HiveField(3)
  DateTime createdAt;
}
