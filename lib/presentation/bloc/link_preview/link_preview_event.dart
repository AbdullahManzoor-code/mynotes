import 'package:equatable/equatable.dart';

abstract class LinkPreviewEvent extends Equatable {
  const LinkPreviewEvent();

  @override
  List<Object?> get props => [];
}

class InitializeLinkPreviewEvent extends LinkPreviewEvent {
  final String url;

  const InitializeLinkPreviewEvent(this.url);

  @override
  List<Object?> get props => [url];
}

class ValidateUrlEvent extends LinkPreviewEvent {
  final String url;

  const ValidateUrlEvent(this.url);

  @override
  List<Object?> get props => [url];
}

class FetchPreviewEvent extends LinkPreviewEvent {
  final String url;

  const FetchPreviewEvent(this.url);

  @override
  List<Object?> get props => [url];
}

class ClearPreviewEvent extends LinkPreviewEvent {
  const ClearPreviewEvent();
}

class RetryFetchEvent extends LinkPreviewEvent {
  const RetryFetchEvent();
}
