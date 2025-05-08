import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image2text/core/services/permission_handle/request_camera_permission.dart';
import 'package:image2text/features/translate_text/model/folder_model/folder_model.dart';
import 'package:image2text/features/translate_text/model/translation_model/translation_model.dart';
import 'package:image2text/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive
    ..registerAdapter(FolderModelAdapter())
    ..registerAdapter(TranslationModelAdapter());

  await Hive.openBox<FolderModel>('folders');
  await Hive.openBox<TranslationModel>('translations');

  await requestCameraPermission();
  runApp(const MyApp());
}
