import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:ui' as ui;
import '../design_system/design_system.dart';
import '../bloc/search/search_bloc.dart';
import '../../domain/entities/note.dart';

/// Enhanced Global Search Results Screen
/// Advanced search with real-time results and filters
/// Refactored to use SearchBloc for centralized state management
class EnhancedGlobalSearchScreen extends StatelessWidget {
  final String? initialQuery;

  const EnhancedGlobalSearchScreen({super.key, this.initialQuery});

  @override
  Widget build(BuildContext context) {
    return _SearchLifecycleWrapper(
      initialQuery: initialQuery,
      child: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          if (state is! SearchLoaded) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return Scaffold(
            backgroundColor: AppColors.darkBackground,
            body: Column(
              children: [
                _buildSearchHeader(context, state),
                _buildFilterSection(context, state),
                Expanded(child: _buildSearchContent(context, state)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchHeader(BuildContext context, SearchLoaded state) {
    return Container(
      color: AppColors.darkBackground.withOpacity(0.95),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Global Search',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),

                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Search bar
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
                child: _buildSearchBar(context, state),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, SearchLoaded state) {
    final wrapper = _SearchLifecycleWrapper.of(context);
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: AppColors.darkCardBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: state.isListening
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
        boxShadow: state.isListening
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Icon(
              state.isListening ? Icons.mic : Icons.search,
              color: state.isListening
                  ? AppColors.primary
                  : Colors.grey.shade500,
              size: 24.sp,
            ),
          ),

          Expanded(
            child: TextField(
              controller: wrapper?.searchController,
              focusNode: wrapper?.searchFocusNode,
              style: TextStyle(fontSize: 16.sp, color: Colors.white),
              decoration: InputDecoration(
                hintText: state.isListening
                    ? 'Listening...'
                    : 'Search notes, todos...',
                hintStyle: TextStyle(
                  fontSize: 16.sp,
                  color: state.isListening
                      ? AppColors.primary.withOpacity(0.7)
                      : Colors.grey.shade500,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (query) {
                if (query.isNotEmpty) {
                  context.read<SearchBloc>().add(PerformSearch(query));
                }
              },
            ),
          ),

          // Voice search button
          if (state.isVoiceAvailable && !state.isListening)
            GestureDetector(
              onTap: () => wrapper?.startVoiceSearch(),
              child: Container(
                padding: EdgeInsets.all(8.w),
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.mic_outlined,
                  color: AppColors.primary,
                  size: 20.sp,
                ),
              ),
            ),

          // Stop voice button
          if (state.isListening)
            GestureDetector(
              onTap: () => wrapper?.stopVoiceSearch(),
              child: Container(
                padding: EdgeInsets.all(8.w),
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(Icons.stop, color: Colors.red, size: 20.sp),
              ),
            ),

          // Clear button
          if ((wrapper?.searchController.text.isNotEmpty ?? false) &&
              !state.isListening)
            GestureDetector(
              onTap: () => wrapper?.clearSearch(),
              child: Container(
                padding: EdgeInsets.all(8.w),
                child: Icon(
                  Icons.close,
                  color: Colors.grey.shade500,
                  size: 20.sp,
                ),
              ),
            ),

          // Filter button
          GestureDetector(
            onTap: () => context.read<SearchBloc>().add(ToggleFilters()),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Icon(
                Icons.tune,
                color: state.showFilters
                    ? AppColors.primary
                    : Colors.grey.shade500,
                size: 24.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context, SearchLoaded state) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: state.showFilters
          ? Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.darkCardBackground,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade800, width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FILTERS',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: Colors.grey.shade500,
                    ),
                  ),

                  SizedBox(height: 12.h),

                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      _buildFilterChip(
                        context,
                        'All',
                        SearchFilter.all,
                        state.selectedFilter,
                      ),
                      _buildFilterChip(
                        context,
                        'Notes',
                        SearchFilter.notes,
                        state.selectedFilter,
                      ),
                      _buildFilterChip(
                        context,
                        'Todos',
                        SearchFilter.todos,
                        state.selectedFilter,
                      ),
                      _buildFilterChip(
                        context,
                        'Reminders',
                        SearchFilter.reminders,
                        state.selectedFilter,
                      ),
                    ],
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    SearchFilter value,
    SearchFilter selected,
  ) {
    final isSelected = selected == value;

    return GestureDetector(
      onTap: () => context.read<SearchBloc>().add(ApplyFilter(value)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.2)
              : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade700,
          ),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: isSelected ? AppColors.primary : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchContent(BuildContext context, SearchLoaded state) {
    if (state.isSearching) {
      return _buildLoadingState();
    }

    if (state.searchQuery.isEmpty) {
      return _buildRecentSearches(state);
    }

    if (state.searchResults.isEmpty) {
      return _buildEmptyResults();
    }

    return _buildSearchResults(context, state);
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            strokeWidth: 2,
          ),
          SizedBox(height: 16.h),
          Text(
            'Searching...',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches(SearchLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Text(
            'RECENT SEARCHES',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Colors.grey.shade500,
            ),
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: state.recentSearches.length,
            itemBuilder: (context, index) {
              final search = state.recentSearches[index];
              return ListTile(
                leading: Icon(
                  Icons.history,
                  color: Colors.grey.shade500,
                  size: 20.sp,
                ),
                title: Text(
                  search,
                  style: TextStyle(fontSize: 16.sp, color: Colors.white),
                ),
                onTap: () =>
                    context.read<SearchBloc>().add(PerformSearch(search)),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80.sp, color: Colors.grey.shade700),
          SizedBox(height: 16.h),
          Text(
            'No results found',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Try a different search term',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, SearchLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Text(
            '${state.searchResults.length} RESULTS',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Colors.grey.shade500,
            ),
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: state.searchResults.length,
            itemBuilder: (_, index) {
              final note = state.searchResults[index];
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _buildSearchResultCard(context, note),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResultCard(BuildContext context, Note note) {
    return GestureDetector(
      onTap: () async {
        if (context.mounted) {
          Navigator.pop(context);
          if (context.mounted) {
            Navigator.pushNamed(
              context,
              '/notes/editor/enhanced',
              arguments: {'note': note},
            );
          }
        }
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.darkCardBackground,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade800, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            if (note.content.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text(
                note.content,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade400,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            SizedBox(height: 12.h),

            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16.sp,
                  color: Colors.grey.shade500,
                ),
                SizedBox(width: 4.w),
                Text(
                  _formatDate(note.updatedAt),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade500,
                  ),
                ),

                const Spacer(),

                Icon(
                  Icons.arrow_forward_ios,
                  size: 16.sp,
                  color: Colors.grey.shade500,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _SearchLifecycleWrapper extends StatefulWidget {
  final Widget child;
  final String? initialQuery;

  const _SearchLifecycleWrapper({required this.child, this.initialQuery});

  @override
  State<_SearchLifecycleWrapper> createState() =>
      _SearchLifecycleWrapperState();

  static _SearchLifecycleWrapperState? of(BuildContext context) {
    return context.findAncestorStateOfType<_SearchLifecycleWrapperState>();
  }
}

class _SearchLifecycleWrapperState extends State<_SearchLifecycleWrapper> {
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  late stt.SpeechToText _speechToText;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
    _initializeVoiceSearch();

    // Initialize search bloc with initial query
    context.read<SearchBloc>().add(
      InitializeSearch(initialQuery: widget.initialQuery),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = searchController.text;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        context.read<SearchBloc>().add(SearchQueryChanged(query.trim()));
        if (query.trim().isNotEmpty) {
          context.read<SearchBloc>().add(PerformSearch(query.trim()));
        } else {
          context.read<SearchBloc>().add(ClearSearch());
        }
      }
    });
  }

  void clearSearch() {
    searchController.clear();
    context.read<SearchBloc>().add(ClearSearch());
    searchFocusNode.requestFocus();
  }

  Future<void> _initializeVoiceSearch() async {
    _speechToText = stt.SpeechToText();
    await _speechToText.initialize(
      onStatus: (status) {
        if (status == 'notListening') {
          context.read<SearchBloc>().add(StopVoiceSearch());
        }
      },
      onError: (error) => _handleVoiceError(error),
    );
  }

  Future<void> startVoiceSearch() async {
    final permission = await Permission.microphone.request();
    if (permission != PermissionStatus.granted) {
      _showErrorSnackbar('Microphone permission required');
      return;
    }

    context.read<SearchBloc>().add(StartVoiceSearch());
    await _speechToText.listen(
      onResult: (result) {
        searchController.text = result.recognizedWords;
        context.read<SearchBloc>().add(
          VoiceSearchResult(
            result.recognizedWords,
            isFinal: result.finalResult,
          ),
        );
      },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 2),
    );
  }

  void stopVoiceSearch() {
    _speechToText.stop();
    context.read<SearchBloc>().add(StopVoiceSearch());
  }

  void _handleVoiceError(dynamic error) {
    context.read<SearchBloc>().add(StopVoiceSearch());
    _showErrorSnackbar('Voice recognition error');
  }

  void _showErrorSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          margin: EdgeInsets.all(16.w),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SearchBloc, SearchState>(
      listener: (context, state) {
        if (state is SearchLoaded) {
          if (state.searchQuery != searchController.text) {
            searchController.text = state.searchQuery;
          }
        }
      },
      child: widget.child,
    );
  }
}
