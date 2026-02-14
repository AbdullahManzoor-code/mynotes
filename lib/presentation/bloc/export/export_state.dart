part of 'export_bloc.dart';

class ExportState extends Equatable {
  final bool isLoading;
  final bool isSuccess;
  final String? filePath;
  final String? errorMessage;
  final double? progress; // 0.0 to 1.0

  const ExportState({
    this.isLoading = false,
    this.isSuccess = false,
    this.filePath,
    this.errorMessage,
    this.progress,
  });

  ExportState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? filePath,
    String? errorMessage,
    double? progress,
  }) {
    return ExportState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      filePath: filePath ?? this.filePath,
      errorMessage: errorMessage ?? this.errorMessage,
      progress: progress ?? this.progress,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isSuccess,
    filePath,
    errorMessage,
    progress,
  ];
}

class ExportInitial extends ExportState {
  const ExportInitial();
}

class ExportInProgress extends ExportState {
  const ExportInProgress({super.progress}) : super(isLoading: true);
}

class ExportSuccess extends ExportState {
  const ExportSuccess({required String filePath})
    : super(isSuccess: true, filePath: filePath);
}

class ExportError extends ExportState {
  const ExportError({required String message}) : super(errorMessage: message);
}
