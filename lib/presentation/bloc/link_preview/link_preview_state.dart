import 'package:equatable/equatable.dart';

class LinkPreviewMetadata extends Equatable {
  final String url;
  final String title;
  final String? description;
  final String? imageUrl;
  final String? faviconUrl;
  final DateTime createdAt;

  const LinkPreviewMetadata({
    required this.url,
    required this.title,
    this.description,
    this.imageUrl,
    this.faviconUrl,
    required this.createdAt,
  });

  String get domain {
    try {
      return Uri.parse(url).host.replaceFirst('www.', '');
    } catch (e) {
      return 'Link';
    }
  }

  bool get isValidUrl {
    try {
      Uri.parse(url);
      return url.startsWith('http://') || url.startsWith('https://');
    } catch (e) {
      return false;
    }
  }

  @override
  List<Object?> get props => [
    url,
    title,
    description,
    imageUrl,
    faviconUrl,
    createdAt,
  ];
}

abstract class LinkPreviewState extends Equatable {
  const LinkPreviewState();

  @override
  List<Object?> get props => [];
}

class LinkPreviewInitial extends LinkPreviewState {
  const LinkPreviewInitial();
}

class LinkPreviewLoading extends LinkPreviewState {
  final String url;

  const LinkPreviewLoading(this.url);

  @override
  List<Object?> get props => [url];
}

class LinkPreviewValidating extends LinkPreviewState {
  final String url;

  const LinkPreviewValidating(this.url);

  @override
  List<Object?> get props => [url];
}

class LinkPreviewValidationError extends LinkPreviewState {
  final String url;
  final String error;

  const LinkPreviewValidationError({required this.url, required this.error});

  @override
  List<Object?> get props => [url, error];
}

class LinkPreviewLoaded extends LinkPreviewState {
  final LinkPreviewMetadata metadata;

  const LinkPreviewLoaded(this.metadata);

  @override
  List<Object?> get props => [metadata];
}

class LinkPreviewError extends LinkPreviewState {
  final String url;
  final String error;

  const LinkPreviewError({required this.url, required this.error});

  @override
  List<Object?> get props => [url, error];
}

class LinkPreviewEmpty extends LinkPreviewState {
  const LinkPreviewEmpty();
}
