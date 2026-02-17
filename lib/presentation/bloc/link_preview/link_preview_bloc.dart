import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/core/utils/url_validator_util.dart';
import 'link_preview_event.dart';
import 'link_preview_state.dart';

class LinkPreviewBloc extends Bloc<LinkPreviewEvent, LinkPreviewState> {
  LinkPreviewBloc() : super(const LinkPreviewInitial()) {
    on<ValidateUrlEvent>(_onValidateUrl);
    on<InitializeLinkPreviewEvent>(_onInitializeLinkPreview);
    on<FetchPreviewEvent>(_onFetchPreview);
    on<ClearPreviewEvent>(_onClearPreview);
    on<RetryFetchEvent>(_onRetryFetch);
  }

  Future<void> _onValidateUrl(
    ValidateUrlEvent event,
    Emitter<LinkPreviewState> emit,
  ) async {
    emit(LinkPreviewValidating(event.url));

    if (_isValidUrl(event.url)) {
      emit(LinkPreviewValidating(event.url));
    } else {
      emit(
        LinkPreviewValidationError(url: event.url, error: 'Invalid URL format'),
      );
    }
  }

  Future<void> _onInitializeLinkPreview(
    InitializeLinkPreviewEvent event,
    Emitter<LinkPreviewState> emit,
  ) async {
    emit(LinkPreviewLoading(event.url));

    if (!_isValidUrl(event.url)) {
      emit(
        LinkPreviewValidationError(
          url: event.url,
          error: 'Please enter a valid URL',
        ),
      );
      return;
    }

    // Fetch preview - in production, you'd integrate with an OG scraper service
    // For now, we'll just create a basic preview
    try {
      final normalizedUrl = _normalizeUrl(event.url);
      final metadata = LinkPreviewMetadata(
        url: normalizedUrl,
        title: _getDisplayUrl(normalizedUrl),
        description: null,
        imageUrl: null,
        faviconUrl: null,
        createdAt: DateTime.now(),
      );

      emit(LinkPreviewLoaded(metadata));
    } catch (e) {
      emit(
        LinkPreviewError(
          url: event.url,
          error: 'Failed to load preview: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onFetchPreview(
    FetchPreviewEvent event,
    Emitter<LinkPreviewState> emit,
  ) async {
    emit(LinkPreviewLoading(event.url));

    try {
      if (!_isValidUrl(event.url)) {
        emit(
          LinkPreviewValidationError(
            url: event.url,
            error: 'Invalid URL format',
          ),
        );
        return;
      }

      // Simulate preview fetching
      await Future.delayed(const Duration(milliseconds: 500));

      final normalizedUrl = _normalizeUrl(event.url);
      final metadata = LinkPreviewMetadata(
        url: normalizedUrl,
        title: _getDisplayUrl(normalizedUrl),
        description: 'Preview for ${_getDisplayUrl(normalizedUrl)}',
        imageUrl: null,
        faviconUrl: null,
        createdAt: DateTime.now(),
      );

      emit(LinkPreviewLoaded(metadata));
    } catch (e) {
      emit(
        LinkPreviewError(
          url: event.url,
          error: 'Failed to fetch preview: ${e.toString()}',
        ),
      );
    }
  }

  void _onClearPreview(
    ClearPreviewEvent event,
    Emitter<LinkPreviewState> emit,
  ) {
    emit(const LinkPreviewEmpty());
  }

  Future<void> _onRetryFetch(
    RetryFetchEvent event,
    Emitter<LinkPreviewState> emit,
  ) async {
    if (state is LinkPreviewError) {
      final errorState = state as LinkPreviewError;
      add(FetchPreviewEvent(errorState.url));
    }
  }

  bool _isValidUrl(String url) => UrlValidatorUtil.isValidUrl(url);

  String _normalizeUrl(String url) => UrlValidatorUtil.normalizeUrl(url);

  String _getDisplayUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.replaceFirst('www.', '');
    } catch (e) {
      return 'Link';
    }
  }
}
