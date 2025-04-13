import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image2text/recognition_text_cubit/recognition_text_cubit.dart';
import 'package:image2text/recognition_text_widget.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider<RecognitionTextCubit>(
      create: (context) => RecognitionTextCubit(),
      child: const MaterialApp(home: RecognitionTextWidget()),
    );
  }
}
