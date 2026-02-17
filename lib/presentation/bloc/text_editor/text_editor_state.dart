part of 'text_editor_bloc.dart';

class TextEditorState extends Equatable {
  final String content;
  final bool isLoading;
  final bool isSaving;
  final bool isSuccess;
  final String? errorMessage;

  const TextEditorState({
    this.content = '',
    this.isLoading = false,
    this.isSaving = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  TextEditorState copyWith({
    String? content,
    bool? isLoading,
    bool? isSaving,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return TextEditorState(
      content: content ?? this.content,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    content,
    isLoading,
    isSaving,
    isSuccess,
    errorMessage,
  ];
}

class TextEditorInitial extends TextEditorState {
  const TextEditorInitial();
}

class TextEditorLoading extends TextEditorState {
  const TextEditorLoading() : super(isLoading: true);
}

class TextEditorLoaded extends TextEditorState {
  const TextEditorLoaded({required super.content});
}

class TextEditorSaving extends TextEditorState {
  const TextEditorSaving({required super.content}) : super(isSaving: true);
}

class TextEditorSaveSuccess extends TextEditorState {
  const TextEditorSaveSuccess({required super.content})
    : super(isSuccess: true);
}

class TextEditorError extends TextEditorState {
  const TextEditorError({required String message})
    : super(errorMessage: message);
}
