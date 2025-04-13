import 'package:flutter/material.dart';
import 'package:image2text/my_app.dart';
import 'package:image2text/permission_handle/request_camera_permission.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestCameraPermission();
  runApp(const MyApp());
}
