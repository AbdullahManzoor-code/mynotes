import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/core/services/app_logger.dart';
import 'package:mynotes/presentation/widgets/command_palette_widget.dart';
import 'package:mynotes/presentation/widgets/universal_item_card.dart';
import '../bloc/command_palette/command_palette_bloc.dart';
import '../bloc/global_search/global_search_bloc.dart';
import '../design_system/design_system.dart';
import 'enhanced_note_editor_screen.dart';
import '../../injection_container.dart' show getIt;
import '../../domain/models/search_filters.dart';
import '../widgets/search_filter_modal.dart';

/// Global Search & Command Palette Screen
/// Refactored to StatelessWidget using GlobalSearchBloc and Design System
class GlobalSearchScreen extends StatelessWidget {
  const GlobalSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AppLogger.i('GlobalSearchScreen: Building wrapper');
    return BlocProvider(
      create: (context) =>
          GlobalSearchBloc()..add(const SearchQueryChangedEvent('')),
      child: const _GlobalSearchView(),
    );
  }
}

class _GlobalSearchView extends StatefulWidget {
  const _GlobalSearchView();

  @override
  State<_GlobalSearchView> createState() => _GlobalSearchViewState();
}

class _GlobalSearchViewState extends State<_GlobalSearchView> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    AppLogger.i('GlobalSearchScreen: Initialized');
    _searchController = TextEditingController();
    context.read<CommandPaletteBloc>().add(const LoadCommandsEvent());
  }

  @override
  void dispose() {
    AppLogger.i('GlobalSearchScreen: Disposed');
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showFilterModal(
    BuildContext context,
    SearchFilters currentFilters,
  ) async {
    AppLogger.i('GlobalSearchScreen: Showing filter modal');
    final newFilters = await showModalBottomSheet<SearchFilters>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SearchFilterModal(initialFilters: currentFilters),
    );

    if (newFilters != null && mounted) {
      AppLogger.i('GlobalSearchScreen: New filters applied');
      context.read<GlobalSearchBloc>().add(
        SearchFiltersChangedEvent(newFilters),
      );
    }
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
      default:
        getIt<GlobalUiService>().showInfo('Executing: ${command.label}');
        Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GlobalSearchBloc, GlobalSearchState>(
      builder: (context, state) {
        final query = state.params.query;
        final isCommandMode = query.startsWith('/') || query.startsWith('>');

        return Scaffold(
          backgroundColor: AppColors.background(context),
          body: SafeArea(
            child: Column(
              children: [
                CommandPaletteWidget(
                  controller: _searchController,
                  onQueryChanged: (val) {
                    AppLogger.i('GlobalSearchScreen: Query changed: $val');
                    context.read<GlobalSearchBloc>().add(
                      SearchQueryChangedEvent(val),
                    );
                    if (val.startsWith('/') || val.startsWith('>')) {
                      context.read<CommandPaletteBloc>().add(
                        SearchCommandsEvent(val.substring(1)),
                      );
                    }
                  },
                  onClear: () {
                    AppLogger.i('GlobalSearchScreen: Search cleared');
                    _searchController.clear();
                    context.read<GlobalSearchBloc>().add(ClearSearchEvent());
                  },
                  onFilterPressed: () {
                    AppLogger.i('GlobalSearchScreen: Filter button pressed');
                    _showFilterModal(context, state.params.filters);
                  },
                ),
                Expanded(
                  child: isCommandMode
                      ? _buildCommandList(context)
                      : _buildSearchResults(context, state),
                ),
              ],
            ),
          ),
        );
      },
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        // Borderside: Border.all(color: AppColors.borderLight),
      ),
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

  Widget _buildSearchResults(BuildContext context, GlobalSearchState state) {
    final query = state.params.query;
    final results = state.params.searchResults;

    if (query.isEmpty) {
      return _buildEmptyState(context);
    }

    if (state is GlobalSearchLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 80.sp,
              color: AppColors.borderLight,
            ),
            AppSpacing.gapL,
            Text(
              'No results for "$query"',
              style: AppTypography.bodyMedium(context, AppColors.secondaryText),
            ),
          ],
        ),
      );
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

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.search_rounded, size: 100.sp, color: AppColors.primary10),
        AppSpacing.gapXL,
        Text(
          'Search Notes, Todos, and Reminders',
          style: AppTypography.bodyLarge(context, AppColors.secondaryText),
        ),
        AppSpacing.gapXXXL,
        _buildQuickActions(context),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Wrap(
      spacing: 16.w,
      runSpacing: 16.h,
      alignment: WrapAlignment.center,
      children: [
        _buildQuickActionBtn(context, Icons.note_add_rounded, 'New Note', () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EnhancedNoteEditorScreen()),
          );
        }),
        _buildQuickActionBtn(
          context,
          Icons.check_circle_outline_rounded,
          'New Todo',
          () {
            // Navigate to new todo
          },
        ),
        _buildQuickActionBtn(
          context,
          Icons.notification_add_rounded,
          'Reminder',
          () {
            // Navigate to new reminder
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionBtn(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        width: 100.w,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.lightSurface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryColor, size: 28.sp),
            AppSpacing.gapM,
            Text(
              label,
              style: AppTypography.labelSmall(
                context,
                AppColors.secondaryText,
                FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
