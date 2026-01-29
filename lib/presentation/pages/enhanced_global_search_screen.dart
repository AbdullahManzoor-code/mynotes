import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:ui' as ui;
import '../design_system/design_system.dart';
import '../bloc/note_bloc.dart';
import '../bloc/note_event.dart';
import '../bloc/note_state.dart';
import '../../domain/entities/note.dart';

/// Enhanced Global Search Results Screen
/// Advanced search with real-time results and filters
/// Based on global_search_results_1 template
class EnhancedGlobalSearchScreen extends StatefulWidget {
  final String? initialQuery;

  const EnhancedGlobalSearchScreen({super.key, this.initialQuery});

  @override
  State<EnhancedGlobalSearchScreen> createState() =>
      _EnhancedGlobalSearchScreenState();
}

class _EnhancedGlobalSearchScreenState extends State<EnhancedGlobalSearchScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  late AnimationController _filterController;
  late AnimationController _resultsController;
  late AnimationController _voiceController;

  // Voice search
  late stt.SpeechToText _speechToText;
  bool _isListening = false;
  bool _isVoiceAvailable = false;

  String _searchQuery = '';
  List<String> _recentSearches = [];
  List<dynamic> _searchResults = [];
  bool _isSearching = false;
  bool _showFilters = false;

  // Filter options
  String _selectedFilter = 'all'; // all, notes, todos, reminders

  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();

    _filterController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _resultsController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _voiceController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      _searchQuery = widget.initialQuery!;
    }

    _searchController.addListener(_onSearchChanged);
    _initializeVoiceSearch();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
      if (widget.initialQuery != null) {
        _performSearch();
      }
    });

    _loadRecentSearches();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _filterController.dispose();
    _resultsController.dispose();
    _voiceController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted && query.trim() != _searchQuery) {
        setState(() {
          _searchQuery = query.trim();
        });

        if (_searchQuery.isNotEmpty) {
          _performSearch();
        } else {
          setState(() {
            _searchResults = [];
            _isSearching = false;
          });
        }
      }
    });
  }

  void _performSearch() {
    if (_searchQuery.isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    // Add to recent searches
    if (!_recentSearches.contains(_searchQuery)) {
      _recentSearches.insert(0, _searchQuery);
      if (_recentSearches.length > 10) {
        _recentSearches = _recentSearches.take(10).toList();
      }
      _saveRecentSearches();
    }

    // Dispatch search event to NotesBloc
    context.read<NotesBloc>().add(SearchNotesEvent(_searchQuery));
    
    setState(() {
      _isSearching = false;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _searchResults = [];
      _isSearching = false;
    });
    _searchFocusNode.requestFocus();
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });

    if (_showFilters) {
      _filterController.forward();
    } else {
      _filterController.reverse();
    }
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
    });

    if (_searchQuery.isNotEmpty) {
      _performSearch();
    }
  }

  void _loadRecentSearches() {
    // TODO: Load from persistent storage
    setState(() {
      _recentSearches = [
        'Weekly Review',
        'Meeting Notes',
        'Project Planning',
        'Shopping List',
      ];
    });
  }

  void _saveRecentSearches() {
    // TODO: Save to persistent storage
  }

  void _selectRecentSearch(String query) {
    _searchController.text = query;
    setState(() {
      _searchQuery = query;
    });
    _performSearch();
  }

  // Voice search methods
  Future<void> _initializeVoiceSearch() async {
    _speechToText = stt.SpeechToText();
    _isVoiceAvailable = await _speechToText.initialize(
      onStatus: (status) {
        if (status == 'notListening' && _isListening) {
          setState(() {
            _isListening = false;
          });
          _voiceController.reverse();
        }
      },
      onError: (error) => _handleVoiceError(error),
    );
  }

  Future<void> _startVoiceSearch() async {
    if (!_isVoiceAvailable) return;

    final permission = await Permission.microphone.request();
    if (permission != PermissionStatus.granted) {
      _showErrorSnackbar('Microphone permission required');
      return;
    }

    setState(() {
      _isListening = true;
    });
    _voiceController.forward();

    await _speechToText.listen(
      onResult: (result) {
        setState(() {
          _searchController.text = result.recognizedWords;
          _searchQuery = result.recognizedWords;
        });
        if (result.finalResult) {
          _performSearch();
        }
      },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 2),
    );
  }

  void _stopVoiceSearch() {
    _speechToText.stop();
    setState(() {
      _isListening = false;
    });
    _voiceController.reverse();
  }

  void _handleVoiceError(dynamic error) {
    setState(() {
      _isListening = false;
    });
    _voiceController.reverse();
    _showErrorSnackbar('Voice recognition error');
  }

  void _showErrorSnackbar(String message) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Column(
        children: [
          _buildSearchHeader(),
          if (_showFilters) _buildFilterSection(),
          Expanded(child: _buildSearchContent()),
        ],
      ),
    );
  }

  Widget _buildSearchHeader() {
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
                child: _buildSearchBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: AppColors.darkCardBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: _isListening
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
        boxShadow: _isListening
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
              _isListening ? Icons.mic : Icons.search,
              color: _isListening ? AppColors.primary : Colors.grey.shade500,
              size: 24.sp,
            ),
          ),

          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              style: TextStyle(fontSize: 16.sp, color: Colors.white),
              decoration: InputDecoration(
                hintText: _isListening
                    ? 'Listening...'
                    : 'Search notes, todos...',
                hintStyle: TextStyle(
                  fontSize: 16.sp,
                  color: _isListening
                      ? AppColors.primary.withOpacity(0.7)
                      : Colors.grey.shade500,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _performSearch(),
            ),
          ),

          // Voice search button
          if (_isVoiceAvailable && !_isListening)
            GestureDetector(
              onTap: _startVoiceSearch,
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
          if (_isListening)
            GestureDetector(
              onTap: _stopVoiceSearch,
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
          if (_searchController.text.isNotEmpty && !_isListening)
            GestureDetector(
              onTap: _clearSearch,
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
            onTap: _toggleFilters,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Icon(
                Icons.tune,
                color: _showFilters ? AppColors.primary : Colors.grey.shade500,
                size: 24.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
          .animate(
            CurvedAnimation(parent: _filterController, curve: Curves.easeOut),
          ),
      child: Container(
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
                _buildFilterChip('All', 'all'),
                _buildFilterChip('Notes', 'notes'),
                _buildFilterChip('Todos', 'todos'),
                _buildFilterChip('Reminders', 'reminders'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;

    return GestureDetector(
      onTap: () => _applyFilter(value),
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

  Widget _buildSearchContent() {
    if (_isSearching) {
      return _buildLoadingState();
    }

    if (_searchQuery.isEmpty) {
      return _buildRecentSearches();
    }

    if (_searchResults.isEmpty) {
      return _buildEmptyResults();
    }

    return _buildSearchResults();
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

  Widget _buildRecentSearches() {
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
            itemCount: _recentSearches.length,
            itemBuilder: (context, index) {
              final search = _recentSearches[index];
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
                onTap: () => _selectRecentSearch(search),
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

  Widget _buildSearchResults() {
    return FadeTransition(
      opacity: _resultsController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Text(
              '${_searchResults.length} RESULTS',
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
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final note = _searchResults[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: _buildSearchResultCard(note),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultCard(Note note) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(
          context,
          '/notes/editor/enhanced',
          arguments: {'note': note},
        );
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

