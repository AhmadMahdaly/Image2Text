part of 'recognition_text_cubit.dart';

@immutable
sealed class TextState {}

final class TextInitial extends TextState {}

///
final class PickImageLoading extends TextState {}

final class PickImageSuccess extends TextState {}

final class PickImageError extends TextState {
  PickImageError(this.message);
  final String message;
}

///
final class ExtractedTextLoading extends TextState {}

final class ExtractedTextSuccess extends TextState {}

final class ExtractedTextError extends TextState {
  ExtractedTextError(this.message);
  final String message;
}

///
final class SaveTranslationLoading extends TextState {}

final class SaveTranslationSuccess extends TextState {}

final class SaveTranslationError extends TextState {}

///
final class AddNewFolderLoading extends TextState {}

final class AddNewFolderError extends TextState {
  AddNewFolderError(this.message);
  final String message;
}

final class AddNewFolderSuccess extends TextState {}

///
final class RenameTitleLoading extends TextState {}

final class RenameTitleError extends TextState {}

final class RenameTitleSuccess extends TextState {}

///
final class DeleteTranslationLoading extends TextState {}

final class DeleteTranslationSuccess extends TextState {}

final class DeleteTranslationError extends TextState {
  DeleteTranslationError(this.message);
  final String message;
}

///
final class RenameFolderLoading extends TextState {}

final class RenameFolderSuccess extends TextState {}

///
final class DeleteFolderLoading extends TextState {}

final class DeleteFolderSuccess extends TextState {}

final class SelectedFolderChanged extends TextState {}
