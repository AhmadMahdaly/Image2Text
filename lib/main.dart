import 'package:flutter/material.dart';
import 'package:image2text/features/recognition_text/services/permission_handle/request_camera_permission.dart';
import 'package:image2text/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestCameraPermission();
  runApp(const MyApp());
}
