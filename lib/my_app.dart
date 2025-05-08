import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image2text/core/cubit/recognition_text_cubit.dart';
import 'package:image2text/core/services/unfocus_scope.dart';
import 'package:image2text/features/recognition_text/view/recognition_text_view.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => unfocusScope(context),
      child: BlocProvider<TextCubit>(
        create: (context) => TextCubit(),
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: RecognitionTextScreen(),
        ),
      ),
    );
  }
}
