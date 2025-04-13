part of 'recognition_text_cubit.dart';

@immutable
sealed class RecognitionTextState {}

final class RecognitionTextInitial extends RecognitionTextState {}

final class PickImageLoading extends RecognitionTextState {}

final class PickImageSuccess extends RecognitionTextState {}

final class PickImageError extends RecognitionTextState {
  PickImageError(this.message);
  final String message;
}

final class ExtractedTextLoading extends RecognitionTextState {}

final class ExtractedTextSuccess extends RecognitionTextState {}

final class ExtractedTextError extends RecognitionTextState {
  ExtractedTextError(this.message);
  final String message;
}
