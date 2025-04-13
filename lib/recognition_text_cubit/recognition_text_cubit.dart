import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'recognition_text_state.dart';

class RecognitionTextCubit extends Cubit<RecognitionTextState> {
  RecognitionTextCubit() : super(RecognitionTextInitial());
}
