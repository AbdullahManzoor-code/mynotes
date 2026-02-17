import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'package:mynotes/core/routes/app_routes.dart';
import 'package:mynotes/domain/models/search_filters.dart';
import 'package:mynotes/presentation/bloc/command_palette/command_palette_bloc.dart';
import 'package:mynotes/presentation/bloc/global_search/global_search_bloc.dart';
import 'package:mynotes/presentation/design_system/design_system.dart';
import 'package:mynotes/presentation/widgets/search_filter_modal.dart';
import 'package:mynotes/presentation/widgets/universal_item_card.dart';

import '../../injection_container.dart' show getIt;
import 'enhanced_note_editor_screen.dart';

/// Global Search & Command Palette Screen
/// Consolidated UI with voice search, filters, and command palette mode.
class GlobalSearchScreen extends StatelessWidget {
  final String? initialQuery;

  const GlobalSearchScreen({super.key, this.initialQuery});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<GlobalSearchBloc>()),
        BlocProvider(
          create: (_) =>
              getIt<CommandPaletteBloc>()..add(const LoadCommandsEvent()),
        ),
      ],
      child: _SearchLifecycleWrapper(
        initialQuery: initialQuery,
        child: BlocBuilder<GlobalSearchBloc, GlobalSearchState>(
          builder: (context, state) {
            final wrapper = _SearchLifecycleWrapper.of(context);
            final queryText = wrapper?.searchController.text ?? '';
            final isCommandMode = _isCommandMode(queryText);

            return Scaffold(
              backgroundColor: AppColors.darkBackground,
              body: Column(
                children: [
                  _buildSearchHeader(context, state, queryText),
                  Expanded(
                    child: isCommandMode
                        ? _buildCommandList(context)
                        : _buildSearchContent(context, state, queryText),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  static bool _isCommandMode(String query) {
    return query.startsWith('/') || query.startsWith('>');
  }

  Future<void> _showFilterModal(
    BuildContext context,
    SearchFilters currentFilters,
  ) async {
    final newFilters = await showModalBottomSheet<SearchFilters>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SearchFilterModal(initialFilters: currentFilters),
    );

    if (newFilters != null && context.mounted) {
      context.read<GlobalSearchBloc>().add(
        SearchFiltersChangedEvent(newFilters),
      );
    }
  }

  Widget _buildSearchHeader(
    BuildContext context,
    GlobalSearchState state,
    String query,
  ) {
    return Container(
      color: AppColors.darkBackground.withOpacity(0.95),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: SafeArea(
          child: Column(
            children: [
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
                      onTap: () {
                        AppLogger.i('GlobalSearchScreen: Cancel pressed');
                        Navigator.pop(context);
                      },
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
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
                child: _buildSearchBar(context, state, query),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(
    BuildContext context,
    GlobalSearchState state,
    String query,
  ) {
    final wrapper = _SearchLifecycleWrapper.of(context);
    final isListening = wrapper?.isListening ?? false;
    final hasFilters = _hasActiveFilters(state.params.filters);

    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: AppColors.darkCardBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: isListening
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Icon(
              isListening ? Icons.mic : Icons.search,
              color: isListening ? AppColors.primary : Colors.grey.shade500,
              size: 24.sp,
            ),
          ),
          Expanded(
            child: TextField(
              controller: wrapper?.searchController,
              focusNode: wrapper?.searchFocusNode,
              style: TextStyle(fontSize: 16.sp, color: Colors.white),
              decoration: InputDecoration(
                hintText: isListening
                    ? 'Listening...'
                    : 'Search notes, todos, reminders...',
                hintStyle: TextStyle(
                  fontSize: 16.sp,
                  color: isListening
                      ? AppColors.primary.withOpacity(0.7)
                      : Colors.grey.shade500,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                if (value.isNotEmpty && !_isCommandMode(value)) {
                  context.read<GlobalSearchBloc>().add(
                    SearchQueryChangedEvent(value),
                  );
                }
              },
            ),
          ),
          if (!isListening)
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
          if (isListening)
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
          if (query.isNotEmpty && !isListening)
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
          GestureDetector(
            onTap: () => _showFilterModal(context, state.params.filters),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  Icon(
                    Icons.tune,
                    color: hasFilters
                        ? AppColors.primary
                        : Colors.grey.shade500,
                    size: 24.sp,
                  ),
                  if (hasFilters)
                    Container(
                      width: 8.w,
                      height: 8.w,
                      margin: EdgeInsets.only(top: 2.h, right: 2.w),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasActiveFilters(SearchFilters filters) {
    return filters.types.isNotEmpty ||
        filters.startDate != null ||
        filters.endDate != null ||
        filters.category != null ||
        filters.sortBy != 'updated_at' ||
        filters.sortDescending == false;
  }

  Widget _buildSearchContent(
    BuildContext context,
    GlobalSearchState state,
    String query,
  ) {
    if (state is GlobalSearchLoading || state.params.isSearching) {
      return _buildLoadingState();
    }

    if (query.isEmpty) {
      return _buildEmptyState();
    }

    final results = state.params.searchResults;
    if (results.isEmpty) {
      return _buildEmptyResults(query);
    }

    return ListView.builder(
      padding: AppSpacing.paddingAllL,
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return UniversalItemCard(item: item);
      },
    );
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 80.sp, color: Colors.grey.shade700),
          SizedBox(height: 16.h),
          Text(
            'Start typing to search',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyResults(String query) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80.sp, color: Colors.grey.shade700),
          SizedBox(height: 16.h),
          Text(
            'No results for "$query"',
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

  Widget _buildCommandList(BuildContext context) {
    return BlocBuilder<CommandPaletteBloc, CommandPaletteState>(
      builder: (context, state) {
        if (state is CommandPaletteFiltered) {
          return ListView.builder(
            padding: AppSpacing.paddingAllL,
            itemCount: state.filteredCommands.length,
            itemBuilder: (context, index) {
              final cmd = state.filteredCommands[index];
              return _buildCommandTile(context, cmd);
            },
          );
        } else if (state is CommandPaletteOpen) {
          return ListView.builder(
            padding: AppSpacing.paddingAllL,
            itemCount: state.commands.length,
            itemBuilder: (context, index) {
              final cmd = state.commands[index];
              return _buildCommandTile(context, cmd);
            },
          );
        }
        return const Center(child: Text('No matching commands'));
      },
    );
  }

  Widget _buildCommandTile(BuildContext context, CommandItem cmd) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 0,
      color: AppColors.lightSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: AppColors.primary10,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            Icons.terminal_rounded,
            color: AppColors.primaryColor,
            size: 20.sp,
          ),
        ),
        title: Text(
          cmd.label,
          style: AppTypography.bodyMedium(context, null, FontWeight.w600),
        ),
        subtitle: Text(
          cmd.description ?? '',
          style: AppTypography.bodySmall(context, AppColors.secondaryText),
        ),
        trailing: cmd.shortcut != null
            ? Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.background(context),
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Text(
                  cmd.shortcut!,
                  style: AppTypography.labelSmall(
                    context,
                    AppColors.secondaryText,
                    FontWeight.bold,
                  ),
                ),
              )
            : null,
        onTap: () => _handleCommandSelection(context, cmd),
      ),
    );
  }

  void _handleCommandSelection(BuildContext context, CommandItem command) {
    AppLogger.i('GlobalSearchScreen: Command selected: ${command.label}');
    switch (command.id) {
      case 'new_note':
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EnhancedNoteEditorScreen()),
        );
        break;
      case 'search':
        Navigator.pop(context);
        Navigator.pushNamed(context, AppRoutes.globalSearch);
        break;
      default:
        getIt<GlobalUiService>().showInfo('Executing: ${command.label}');
        Navigator.pop(context);
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
  bool _isListening = false;

  bool get isListening => _isListening;

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
    _initializeVoiceSearch();
    context.read<CommandPaletteBloc>().add(const LoadCommandsEvent());

    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      searchController.text = widget.initialQuery!;
      _dispatchQuery(widget.initialQuery!);
    }

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
    _debounceTimer = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      _dispatchQuery(query.trim());
    });
  }

  void _dispatchQuery(String query) {
    if (query.isEmpty) {
      context.read<GlobalSearchBloc>().add(ClearSearchEvent());
      return;
    }

    if (GlobalSearchScreen._isCommandMode(query)) {
      final trimmed = query.substring(1).trim();
      context.read<CommandPaletteBloc>().add(SearchCommandsEvent(trimmed));
      return;
    }

    context.read<GlobalSearchBloc>().add(SearchQueryChangedEvent(query));
  }

  void clearSearch() {
    searchController.clear();
    context.read<GlobalSearchBloc>().add(ClearSearchEvent());
    searchFocusNode.requestFocus();
  }

  Future<void> _initializeVoiceSearch() async {
    _speechToText = stt.SpeechToText();
    await _speechToText.initialize(
      onStatus: (status) {
        if (status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
      onError: (error) => _showErrorSnackbar('Voice recognition error'),
    );
  }

  Future<void> startVoiceSearch() async {
    final permission = await Permission.microphone.request();
    if (permission != PermissionStatus.granted) {
      _showErrorSnackbar('Microphone permission required');
      return;
    }

    setState(() => _isListening = true);
    await _speechToText.listen(
      onResult: (result) {
        searchController.text = result.recognizedWords;
      },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 2),
    );
  }

  void stopVoiceSearch() {
    _speechToText.stop();
    setState(() => _isListening = false);
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
    return widget.child;
  }
}
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:mynotes/core/services/app_logger.dart';
// import 'package:mynotes/presentation/widgets/command_palette_widget.dart';
// import 'package:mynotes/presentation/widgets/universal_item_card.dart';
// import '../bloc/command_palette/command_palette_bloc.dart';
// import '../bloc/global_search/global_search_bloc.dart';
// import '../design_system/design_system.dart';
// import 'enhanced_note_editor_screen.dart';
// import '../../injection_container.dart' show getIt;
// import '../../domain/models/search_filters.dart';
// import '../widgets/search_filter_modal.dart';

// /// Global Search & Command Palette Screen
// /// Refactored to StatelessWidget using GlobalSearchBloc and Design System
// class GlobalSearchScreen extends StatelessWidget {
//   const GlobalSearchScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     AppLogger.i('GlobalSearchScreen: Building wrapper');
//     return BlocProvider(
//       create: (context) =>
//           GlobalSearchBloc()..add(const SearchQueryChangedEvent('')),
//       child: const _GlobalSearchView(),
//     );
//   }
// }

// class _GlobalSearchView extends StatefulWidget {
//   const _GlobalSearchView();

//   @override
//   State<_GlobalSearchView> createState() => _GlobalSearchViewState();
// }

// class _GlobalSearchViewState extends State<_GlobalSearchView> {
//   late final TextEditingController _searchController;

//   @override
//   void initState() {
//     super.initState();
//     AppLogger.i('GlobalSearchScreen: Initialized');
//     _searchController = TextEditingController();
//     context.read<CommandPaletteBloc>().add(const LoadCommandsEvent());
//   }

//   @override
//   void dispose() {
//     AppLogger.i('GlobalSearchScreen: Disposed');
//     _searchController.dispose();
//     super.dispose();
//   }

//   Future<void> _showFilterModal(
//     BuildContext context,
//     SearchFilters currentFilters,
//   ) async {
//     AppLogger.i('GlobalSearchScreen: Showing filter modal');
//     final newFilters = await showModalBottomSheet<SearchFilters>(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => SearchFilterModal(initialFilters: currentFilters),
//     );

//     if (newFilters != null && mounted) {
//       AppLogger.i('GlobalSearchScreen: New filters applied');
//       context.read<GlobalSearchBloc>().add(
//         SearchFiltersChangedEvent(newFilters),
//       );
//     }
//   }

//   void _handleCommandSelection(BuildContext context, CommandItem command) {
//     AppLogger.i('GlobalSearchScreen: Command selected: ${command.label}');
//     switch (command.id) {
//       case 'new_note':
//         Navigator.pop(context);
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => const EnhancedNoteEditorScreen()),
//         );
//         break;
//       default:
//         getIt<GlobalUiService>().showInfo('Executing: ${command.label}');
//         Navigator.pop(context);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<GlobalSearchBloc, GlobalSearchState>(
//       builder: (context, state) {
//         final query = state.params.query;
//         final isCommandMode = query.startsWith('/') || query.startsWith('>');

//         return Scaffold(
//           backgroundColor: AppColors.background(context),
//           body: SafeArea(
//             child: Column(
//               children: [
//                 CommandPaletteWidget(
//                   controller: _searchController,
//                   onQueryChanged: (val) {
//                     AppLogger.i('GlobalSearchScreen: Query changed: $val');
//                     context.read<GlobalSearchBloc>().add(
//                       SearchQueryChangedEvent(val),
//                     );
//                     if (val.startsWith('/') || val.startsWith('>')) {
//                       context.read<CommandPaletteBloc>().add(
//                         SearchCommandsEvent(val.substring(1)),
//                       );
//                     }
//                   },
//                   onClear: () {
//                     AppLogger.i('GlobalSearchScreen: Search cleared');
//                     _searchController.clear();
//                     context.read<GlobalSearchBloc>().add(ClearSearchEvent());
//                   },
//                   onFilterPressed: () {
//                     AppLogger.i('GlobalSearchScreen: Filter button pressed');
//                     _showFilterModal(context, state.params.filters);
//                   },
//                 ),
//                 Expanded(
//                   child: isCommandMode
//                       ? _buildCommandList(context)
//                       : _buildSearchResults(context, state),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildCommandList(BuildContext context) {
//     return BlocBuilder<CommandPaletteBloc, CommandPaletteState>(
//       builder: (context, state) {
//         if (state is CommandPaletteFiltered) {
//           return ListView.builder(
//             padding: AppSpacing.paddingAllL,
//             itemCount: state.filteredCommands.length,
//             itemBuilder: (context, index) {
//               final cmd = state.filteredCommands[index];
//               return _buildCommandTile(context, cmd);
//             },
//           );
//         } else if (state is CommandPaletteOpen) {
//           return ListView.builder(
//             padding: AppSpacing.paddingAllL,
//             itemCount: state.commands.length,
//             itemBuilder: (context, index) {
//               final cmd = state.commands[index];
//               return _buildCommandTile(context, cmd);
//             },
//           );
//         }
//         return const Center(child: Text('No matching commands'));
//       },
//     );
//   }

//   Widget _buildCommandTile(BuildContext context, CommandItem cmd) {
//     return Card(
//       margin: EdgeInsets.only(bottom: 12.h),
//       elevation: 0,
//       color: AppColors.lightSurface,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16.r),
//         // Borderside: Border.all(color: AppColors.borderLight),
//       ),
//       child: ListTile(
//         leading: Container(
//           padding: EdgeInsets.all(8.r),
//           decoration: BoxDecoration(
//             color: AppColors.primary10,
//             borderRadius: BorderRadius.circular(10.r),
//           ),
//           child: Icon(
//             Icons.terminal_rounded,
//             color: AppColors.primaryColor,
//             size: 20.sp,
//           ),
//         ),
//         title: Text(
//           cmd.label,
//           style: AppTypography.bodyMedium(context, null, FontWeight.w600),
//         ),
//         subtitle: Text(
//           cmd.description ?? '',
//           style: AppTypography.bodySmall(context, AppColors.secondaryText),
//         ),
//         trailing: cmd.shortcut != null
//             ? Container(
//                 padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
//                 decoration: BoxDecoration(
//                   color: AppColors.background(context),
//                   borderRadius: BorderRadius.circular(6.r),
//                   border: Border.all(color: AppColors.borderLight),
//                 ),
//                 child: Text(
//                   cmd.shortcut!,
//                   style: AppTypography.labelSmall(
//                     context,
//                     AppColors.secondaryText,
//                     FontWeight.bold,
//                   ),
//                 ),
//               )
//             : null,
//         onTap: () => _handleCommandSelection(context, cmd),
//       ),
//     );
//   }

//   Widget _buildSearchResults(BuildContext context, GlobalSearchState state) {
//     final query = state.params.query;
//     final results = state.params.searchResults;

//     if (query.isEmpty) {
//       return _buildEmptyState(context);
//     }

//     if (state is GlobalSearchLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (results.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.search_off_rounded,
//               size: 80.sp,
//               color: AppColors.borderLight,
//             ),
//             AppSpacing.gapL,
//             Text(
//               'No results for "$query"',
//               style: AppTypography.bodyMedium(context, AppColors.secondaryText),
//             ),
//           ],
//         ),
//       );
//     }

//     return ListView.builder(
//       padding: AppSpacing.paddingAllL,
//       itemCount: results.length,
//       itemBuilder: (context, index) {
//         final item = results[index];
//         return UniversalItemCard(item: item);
//       },
//     );
//   }

//   Widget _buildEmptyState(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Icon(Icons.search_rounded, size: 100.sp, color: AppColors.primary10),
//         AppSpacing.gapXL,
//         Text(
//           'Search Notes, Todos, and Reminders',
//           style: AppTypography.bodyLarge(context, AppColors.secondaryText),
//         ),
//         AppSpacing.gapXXXL,
//         _buildQuickActions(context),
//       ],
//     );
//   }

//   Widget _buildQuickActions(BuildContext context) {
//     return Wrap(
//       spacing: 16.w,
//       runSpacing: 16.h,
//       alignment: WrapAlignment.center,
//       children: [
//         _buildQuickActionBtn(context, Icons.note_add_rounded, 'New Note', () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => const EnhancedNoteEditorScreen()),
//           );
//         }),
//         _buildQuickActionBtn(
//           context,
//           Icons.check_circle_outline_rounded,
//           'New Todo',
//           () {
//             // Navigate to new todo
//           },
//         ),
//         _buildQuickActionBtn(
//           context,
//           Icons.notification_add_rounded,
//           'Reminder',
//           () {
//             // Navigate to new reminder
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildQuickActionBtn(
//     BuildContext context,
//     IconData icon,
//     String label,
//     VoidCallback onTap,
//   ) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(16.r),
//       child: Container(
//         width: 100.w,
//         padding: EdgeInsets.symmetric(vertical: 16.h),
//         decoration: BoxDecoration(
//           color: AppColors.lightSurface,
//           borderRadius: BorderRadius.circular(16.r),
//           border: Border.all(color: AppColors.borderLight),
//         ),
//         child: Column(
//           children: [
//             Icon(icon, color: AppColors.primaryColor, size: 28.sp),
//             AppSpacing.gapM,
//             Text(
//               label,
//               style: AppTypography.labelSmall(
//                 context,
//                 AppColors.secondaryText,
//                 FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
